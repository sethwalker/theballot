require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contests::BaseController do
  fixtures :contests, :guides, :users
  def setup
    @controller = Contests::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_not_c3
    @request.host = APPLICATION_STANDARD_DOMAIN
    get :new
    assert !@controller.send('c3?')
  end

  def test_c3
    @request.host = APPLICATION_C3_DOMAIN
    get :new
    assert @controller.send('c3?')
  end
end
