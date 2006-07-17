class Attachment < ActiveRecord::Base
  acts_as_attachment :storage => :file_system

  def url(version=nil)
    public_filename(version)
  end
end
