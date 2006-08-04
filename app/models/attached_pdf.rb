class AttachedPdf < Attachment
  acts_as_attachment :content_type => 'application/pdf'
  validates_as_attachment
  belongs_to :guide
  belongs_to :user
end
