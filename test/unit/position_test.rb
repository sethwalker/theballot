require File.dirname(__FILE__) + '/../test_helper'

class PositionTest < Test::Unit::TestCase
  fixtures :positions

  # Replace this with your real tests.
  def test_count
    assert_equal Position.count, 2
  end
end
