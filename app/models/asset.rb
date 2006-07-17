class Asset < ActiveRecord::Base
  include FileColumnHelper
	file_column :path, :magick => {:versions => {"thumb" => "50x50"}, :image_required => false}

  def url(options=nil)
    url_for_file_column self, "path", options
  end
end
