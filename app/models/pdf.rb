class PDF < Attachment
  acts_as_attachment :content_type => 'pdf'
  validates_as_attachment
  belongs_to :guide
end
