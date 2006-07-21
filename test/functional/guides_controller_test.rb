require File.dirname(__FILE__) + '/../test_helper'
require 'guides_controller'

# Re-raise errors caught by the controller.
class GuidesController; def rescue_action(e) raise e end; end

class GuidesControllerTest < Test::Unit::TestCase
  fixtures :guides, :endorsements, :users

  def setup
    @controller = GuidesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:guides)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  def test_preview
    get :show, :id => 2
    assert_response :redirect
    assert_redirected_to :action => :list
    assert flash[:error]

    login_as :arthur
    authorize_as :arthur
    assert @controller.send(:logged_in?)

    @guide = Guide.find(2)
    assert !@guide.is_published?
    assert @guide.owner?(users(:arthur))
    get :show, :id => 2
    raise flash.inspect
    assert_response :success
    assert flash[:notice]
  end

  def test_new
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'

    authorize_as :quentin
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:guide)
  end

  def test_create
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'

    authorize_as :quentin
    num_guides = Guide.count

    post :create, :guide => {:name => 'guide name', :date => Time.now, :description => 'guide description', :city => 'guide city', :state => 'guide state', :owner_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guides + 1, Guide.count
  end

  def test_edit
    get :edit, :id => 3
    assert_redirected_to :controller => 'account', :action => 'login'
    authorize_as :quentin

    get :edit, :id => 3

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  def test_edit_past
    authorize_as :quentin
    get :edit, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  def test_update
    post :update, :id => 3
    assert_redirected_to :controller => 'account', :action => 'login'

    authorize_as :quentin
    post :update, :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 3
  end

  def test_update_past
    authorize_as :quentin
    get :update, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  def test_destroy
    assert_not_nil Guide.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Guide.find(1)
    }
  end
end
