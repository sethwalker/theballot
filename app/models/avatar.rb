class Avatar < Attachment
  acts_as_attachment :content_type => :image, :thumbnails => { :thumb => [35, 35], :display => [50, 50], :profile => '300>x300>', :preview => '150>x150>' }
  validates_as_attachment
  belongs_to :user
end
