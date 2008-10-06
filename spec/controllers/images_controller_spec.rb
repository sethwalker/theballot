require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagesController do
  def setup
    @controller = ImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
