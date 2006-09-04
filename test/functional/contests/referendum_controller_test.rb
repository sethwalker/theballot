require File.dirname(__FILE__) + '/../../test_helper'
require 'contests/referendum_controller'

# Re-raise errors caught by the controller.
class Contests::ReferendumController; def rescue_action(e) raise e end; end

class Contests::ReferendumControllerTest < Test::Unit::TestCase
  def setup
    @controller = Contests::ReferendumController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    true
  end
end
