require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountController do
  fixtures :users, :guides

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    # for testing action mailer
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  def test_profile
    authorize_as :quentin
    get :profile, :id => 1
    assert :success
  end

  def test_should_not_activate_nil
    get :activate, :id => nil
    assert_activate_error
  end

  def test_should_not_activate_bad
    get :activate, :id => 'foobar'
    assert flash.has_key?(:error), "Flash should contain error message." 
    assert_activate_error
  end

  def assert_activate_error
    assert_response :success
    assert_template "account/activate" 
  end

  def test_should_activate_user
    assert_nil User.authenticate('arthur@example.com', 'arthur')
    get :activate, :id => users(:arthur).activation_code
    assigns[:user].save
    assert_equal users(:arthur), User.authenticate('arthur@example.com', 'test')
  end

  def test_should_login_and_redirect
    post :login, :email => 'quentin@example.com', :password => 'test'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :email => 'arthur@example.com', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    lambda {
      create_user
    }.should change(User, :count)
    assert_response :redirect
  end

  def test_should_require_login_on_signup
    create_user(:login => nil)
    lambda {
      create_user(:login => nil)
    }.should_not change(User, :count)
    assert assigns(:user).errors.on(:username)
    assert_response :success
  end

  def test_should_require_password_on_signup
    lambda {
      create_user(:password => nil)
    }.should_not change(User, :count)
    assert assigns(:user).errors.on(:password)
    assert_response :success
  end

  def test_should_require_password_confirmation_on_signup
    lambda {
      create_user(:password_confirmation => nil)
    }.should_not change(User, :count)
    assert assigns(:user).errors.on(:password_confirmation)
    assert_response :success
  end

  def test_should_require_email_on_signup
    lambda {
      create_user(:email => nil)
    }.should_not change(User, :count)
    assert assigns(:user).errors.on(:email)
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  protected
    def create_user(options = {})
      options.symbolize_keys!
      post :signup, :user => new_user.attributes.symbolize_keys!.merge({:password => 'quire', :password_confirmation => 'quire'}).merge(options)
    end
end
