require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < Test::Unit::TestCase
  fixtures :themes

  def test_assets_as_images
    theme = Theme.create({:name => 'theme'})
    image = Image.create({:content_type => 'image/jpeg'})
    theme.images << image
    theme.save!

    new_theme = Theme.find_by_name('theme')
    assert_equal false, new_theme.images.empty?
    assert_equal new_theme.images[0].content_type, 'image/jpeg'
  end

end
