require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contests::ReferendumController do
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
