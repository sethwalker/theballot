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

  def test_authenticated_helpers
    assert !logged_in?
    assert !@controller.send(:logged_in?)

    login_as :quentin
    assert @controller.send(:logged_in?)
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

    @guide = Guide.find(2)
    assert !@guide.is_published?
    assert @guide.owner?(users(:arthur))
    get :show, :id => 2
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

  def test_add_endorsement_to_new
    post :add_endorsement, :endorsement => { :candidate => 'new candidate' }
    assert_equal assigns(:endorsement).candidate, 'new candidate'
  end

  def test_add_endorsement_in_edit
    @guide = Guide.find(1)
    count = @guide.endorsements.count
    post :add_endorsement, :endorsement => { :candidate => 'new candidate' }, :id => 1
    @guide = Guide.find(1)
    assert_equal @guide.endorsements.count, count + 1
    assert @guide.endorsements.find_by_candidate('new candidate')
  end

  def test_order
    @guide = Guide.new(:name => 'reorder test', :date => Time.now)
    @guide.endorsements << Endorsement.find(7,8,9)
    assert @guide.save
    assert_equal Endorsement.find(7).position, 1
    assert_equal Endorsement.find(8).position, 2
    assert_equal Endorsement.find(9).position, 3

    post :order, :endorsements => [3,1,2], :id => @guide.id
    assert_equal Endorsement.find(7).position, 3
    assert_equal Endorsement.find(8).position, 1
    assert_equal Endorsement.find(9).position, 2
  end
end
