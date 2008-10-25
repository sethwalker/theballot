class AttachedPdf < Attachment
  has_attachment :storage => :file_system, :content_type => 'application/pdf', :max_size => TheBallot::ATTACHMENT_SIZE_LIMIT
  validates_as_attachment
  belongs_to :guide
  belongs_to :user
end
