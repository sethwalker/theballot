class Guide < ActiveRecord::Base
  has_many :endorsements
  has_one :image
  has_one :pdf, :class_name => 'PDF'

  belongs_to :owner
  belongs_to :theme

  validates_presence_of :name, :city, :state

  acts_as_draftable :fields => [:name, :city, :state, :date, :description, :owner_id, :theme_id] do
    def self.included(base)
      base.serialize :endorsements, Array
    end
  end

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

end
