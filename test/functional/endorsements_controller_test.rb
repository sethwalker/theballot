require File.dirname(__FILE__) + '/../test_helper'
require 'endorsements_controller'

# Re-raise errors caught by the controller.
class EndorsementsController; def rescue_action(e) raise e end; end

class EndorsementsControllerTest < Test::Unit::TestCase
  fixtures :endorsements, :guides

  def setup
    @controller = EndorsementsController.new
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

    assert_not_nil assigns(:endorsements)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:endorsement)
    assert assigns(:endorsement).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:endorsement)
  end

  def test_create
    num_endorsements = Endorsement.count
    post :create, :endorsement => {:candidate => 'new candidate', :guide_id => 1}
    assert_response :success
    assert_equal Endorsement.count, num_endorsements + 1
  end

  def test_add
    num_endorsements = Endorsement.count
    post :add, :endorsement => {:candidate => 'new candidate'}
    assert_response :success
    assert_equal num_endorsements, Endorsement.count
    assert assigns(:index)
    assert_equal assigns(:index), 0
    assert_equal assigns(:endorsement).candidate, 'new candidate'
    assert_equal assigns(:order), '0'

    post :add, :endorsement => { :candidate => 'second new candidate' }, :index => 1, :current_order => 0
    assert_equal assigns(:index), 1
    assert_equal assigns(:endorsement).candidate, 'second new candidate'
    assert_equal assigns(:order), '0,1'

    post :add, :endorsement => { :candidate => 'third new candidate' }, :index => 2, :current_order => '0,1'
    assert_equal assigns(:index), 2
    assert_equal assigns(:endorsement).candidate, 'third new candidate'
    assert_equal assigns(:order), '0,1,2'
  end

  def test_create_with_guide
    @guide = Guide.find(1)
    num_endorsements = @guide.endorsements.count
    post :create, :endorsement => {:candidate => 'new candidate', :guide_id => 1}
    @guide = Guide.find(1)
    assert_equal @guide.endorsements.count, num_endorsements + 1
    assert @guide.endorsements.find_by_candidate('new candidate')
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:endorsement)
    assert assigns(:endorsement).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :success
  end

  def test_destroy
    assert_not_nil Endorsement.find(1)

    post :destroy, :id => 1
    assert_response :success

    assert_raise(ActiveRecord::RecordNotFound) {
      Endorsement.find(1)
    }
  end
end
