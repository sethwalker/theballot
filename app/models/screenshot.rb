class Screenshot < Attachment
  acts_as_attachment :content_type => :image, :thumbnails => { :thumb => [35, 35], :display => [50, 50], :preview => 'x150' }
  validates_as_attachment
  belongs_to :theme
  belongs_to :user
end
