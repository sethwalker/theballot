require File.dirname(__FILE__) + '/../test_helper'

class GuideTest < Test::Unit::TestCase
  fixtures :guides

  def test_create_with_endorsement
    sf = Guide.find(1)
    assert_equal sf.city, 'san francisco'
#    assert_equal @sanfrancisco.city, 'san francisco'
    sf.city = 'san mateo'
    assert sf.save
    sanmateo = Guide.find(1)
    assert_equal sanmateo.name, 'san mateo'
  end
end
