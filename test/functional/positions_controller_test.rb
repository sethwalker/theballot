require File.dirname(__FILE__) + '/../test_helper'
require 'positions_controller'

# Re-raise errors caught by the controller.
class PositionsController; def rescue_action(e) raise e end; end

class PositionsControllerTest < Test::Unit::TestCase
  fixtures :positions

  def setup
    @controller = PositionsController.new
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

    assert_not_nil assigns(:positions)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:position)
    assert assigns(:position).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:position)
  end

  def test_create
    num_positions = Position.count

    post :create, :position => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_positions + 1, Position.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:position)
    assert assigns(:position).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Position.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Position.find(1)
    }
  end
end
