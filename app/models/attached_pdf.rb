class AttachedPdf < Attachment
  has_attachment :storage => :file_system, :content_type => 'application/pdf', :max_size => 3.megabytes
  validates_as_attachment
  belongs_to :guide
  belongs_to :user
end
