class Theme < ActiveRecord::Base
  has_many :guides
  belongs_to :style
  has_one :screenshot, :dependent => :destroy
  belongs_to :print_style, :class_name => 'Style', :foreign_key => 'print_style_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  def validate
    ['style_url', 'print_style_url'].each do |url|
      if self.send("#{url}?")
        require 'open-uri'
        begin
          open(self.send(url)) do |f|
            unless f.status[0] == '200'
              errors.add 'style_url', ' - could not retrieve file'
            end
            unless f.content_type == 'text/css'
              errors.add 'style_url', 'did not have the correct mime type (text/css)'
            end
          end
        rescue Exception
          errors.add 'style_url', $!
        end
      end
    end
  end

  def markup
    File.read(File.join(RAILS_ROOT, "public/themes/#{template}"))
  end

  def to_liquid
    liquid = { 'name' => name }
    unless author.nil?
      liquid.merge!({ 'author_name' => "#{author.firstname} #{author.lastname}", 'author_url' => author.url })
    end
    return liquid
  end
end
