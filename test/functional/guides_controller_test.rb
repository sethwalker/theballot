require File.dirname(__FILE__) + '/../test_helper'
require 'guides_controller'

# Re-raise errors caught by the controller.
class GuidesController; def rescue_action(e) raise e end; end

class GuidesControllerTest < Test::Unit::TestCase
  fixtures :guides, :users

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

  def test_new
    login_as :quentin
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:guide)
  end

  def test_create
    login_as :quentin
    num_guides = Guide.count

    post :create, :guide => {:name => 'guide name', :description => 'guide description', :city => 'guide city', :state => 'guide state', :owner_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guides + 1, Guide.count
  end

  def test_edit
    login_as :quentin

    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  def test_update
    login_as :quentin
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
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
