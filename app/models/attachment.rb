class Attachment < ActiveRecord::Base
  def url(version=nil)
    public_filename(version)
  end
end
