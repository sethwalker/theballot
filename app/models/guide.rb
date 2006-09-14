class Guide < ActiveRecord::Base
  PUBLISHED = 'Published'
  DRAFT = 'Draft'
  C3 = 'c3'

  has_many :contests, :dependent => :destroy, :include => :choices, :order => 'contests.position'
  has_many :links, :dependent => :destroy
  has_one :image, :dependent => :destroy
  has_one :attached_pdf, :dependent => :destroy

  belongs_to :user
  belongs_to :theme

  has_many :pledges
  has_many :members, :through => :pledges, :source => :user

  before_validation :create_permalink
  validates_presence_of :name, :date, :city, :state

  validates_uniqueness_of :permalink, :scope => :date, :message => "not unique for this election date"

  def validate
    if permalink.nil? || permalink.empty?
      if name.nil? || name.empty?
        errors.add_to_base "Did i mention that name can't be blank? (permalink error)"
      else
        errors.add('permalink', "can't be blank")
      end
    end
  end

  def after_save
    GuidePromoter.deliver_approval_request( { :guide => self } ) if @recently_published
  end

  acts_as_ferret :fields => { :name => {:boost => 3}, 
                              :city => {},
                              :state => {},
                              :description => {:boost => 2.5},
                              :index_contest_choice_titles => {:boost => 2},
                              :index_contest_choice_descriptions => {:boost => 1.5} }

  def index_contest_choice_titles
    index_contest_choices(:name)
  end

  def index_contest_choice_descriptions
    index_contest_choices(:description)
  end

  def index_contest_choices(attr)
    @index = Array.new
    self.contests.each do |contest|
      contest.choices.each do |choice|
        @index << choice.send(attr).to_s
      end
    end
    @index.join(" ")
  end

  def to_liquid
    liquid = { 'id' => id, 'name' => name, 'city' => city, 'state' => state, 'date' => date, 'description' => description, 'contests' => contests }
    if image
      liquid.merge!(  { 'image_link' => image.public_filename, 'image_name' => image.filename, 'image_thumb' => image.public_filename('thumb') } )
    end
    if attached_pdf
      liquid.merge!( { 'pdf_name' => attached_pdf.filename, 'pdf_link' => attached_pdf.public_filename } )
    end
    liquid
  end

  def permalink_url
    "/guides/#{date.year}/#{permalink}"
  end

  def make_permalink(options = {})
    return '/guides/show/' + id if options.empty?
    "/guides/#{options[:year]}/#{options[:permalink]}"
  end

  def publish
    @recently_published = true if !self.status or self.status == DRAFT
    self.status = PUBLISHED
  end

  def unpublish
    self.status = DRAFT
  end

  def is_published?
    PUBLISHED == status
  end

  def approve(user)
    update_attributes(:approved_at => Time.now, :approved_by => user)
  end

  def approved?
    !c3? || !approved_at.nil?
  end

  def owner?(u)
    u == user
  end

  def c3?
    C3 == legal
  end

  def candidate_contests
    contests.find_all_by_type 'Candidate'
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
