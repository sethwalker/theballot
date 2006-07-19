class Guide < ActiveRecord::Base
  has_many :endorsements, :dependent => :destroy, :order => 'sort'
  has_one :image, :dependent => :destroy
  has_one :pdf, :class_name => 'PDF', :dependent => :destroy

  belongs_to :owner
  belongs_to :theme

  validates_presence_of :name

  before_validation_on_create :create_permalink
  validates_uniqueness_of :permalink, :scope => :date, :message => "not unique for this election date"

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
    if pdf
      liquid.merge!( { 'pdf_name' => pdf.filename, 'pdf_link' => pdf.public_filename } )
    end
    liquid
  end

  def permalink_url
    date.strftime("%Y/%m/%d/") + permalink
  end

  protected
  # from acts_as_urlnameable
  def create_permalink
    self.permalink = name.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '_')
  end
end
