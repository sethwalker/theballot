require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
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
    assert_nil User.authenticate('arthur', 'arthur')
    get :activate, :id => users(:arthur).activation_code
    assert_equal users(:arthur), User.authenticate('arthur', 'test')
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'test'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_activate_user_and_send_activation_email
    get :activate, :id => users(:arthur).activation_code
    assert_equal 1, @emails.length
    assert(@emails.first.subject =~ /Your account has been activated/)
    assert(@emails.first.body    =~ /#{assigns(:user).login}, your account has been activated/)
  end

  def test_should_send_activation_email_after_signup
    create_user
    assert_equal 1, @emails.length
    assert(@emails.first.subject =~ /Please activate your new account/)
    assert(@emails.first.body    =~ /Username: quire/)
    assert(@emails.first.body    =~ /Password: quire/)
    assert(@emails.first.body    =~ /account\/activate\/#{assigns(:user).activation_code}/)
  end

  protected
    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
