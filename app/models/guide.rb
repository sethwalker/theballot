class Guide < ActiveRecord::Base
  PUBLISHED = 'Published'
  DRAFT = 'Draft'

  has_many :endorsements, :dependent => :destroy, :order => 'position'
  has_many :links, :dependent => :destroy
  has_one :image, :dependent => :destroy
  has_one :attached_pdf, :dependent => :destroy

  belongs_to :user
  belongs_to :theme

  has_many :pledges
  has_many :members, :through => :pledges, :source => :user

  validates_presence_of :name, :date

  before_validation_on_create :create_permalink
  validates_uniqueness_of :permalink, :scope => :date, :message => "not unique for this election date"

  acts_as_ferret :fields => [ :name, :city, :description ]

=begin
  acts_as_draftable :fields => [:name, :city, :state, :date, :description, :owner_id, :theme_id, :endorsements] do
    def self.included(base)
      base.endorsements.each do |e|
        e.save_draft
      end
    end
  end
=end

  def to_liquid
    liquid = { 'id' => id, 'name' => name, 'city' => city, 'state' => state, 'date' => date, 'description' => description, 'endorsements' => endorsements }
    if image
      liquid.merge!(  { 'image_link' => image.public_filename, 'image_name' => image.filename, 'image_thumb' => image.public_filename('thumb') } )
    end
    if attached_pdf
      liquid.merge!( { 'pdf_name' => attached_pdf.filename, 'pdf_link' => attached_pdf.public_filename } )
    end
    liquid
  end

  def permalink_url
    '/guides/' + date.strftime("%Y/%m/%d/") + permalink
  end

  def publish
    self.status = PUBLISHED
  end

  def unpublish
    self.status = DRAFT
  end

  def is_published?
    PUBLISHED == status
  end

  def owner?(u)
    u == user
  end

  protected
  # from acts_as_urlnameable
  def create_permalink
    if permalink.nil? || permalink.empty?
      self.permalink = name.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '_')
    end
  end

  def validate_on_create
    if !date.nil?
      errors.add 'date', 'must be upcoming election' if date.to_date < Time.now.to_date
    end
  end
end
