require File.dirname(__FILE__) + '/../test_helper'
require 'guides_controller'

# Re-raise errors caught by the controller.
class GuidesController; def rescue_action(e) raise e end; end

class GuidesControllerTest < Test::Unit::TestCase
  fixtures :guides, :contests, :users

  def setup
    @controller = GuidesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:guides)
  end

  def test_show
    get :show, :id => 3

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

    @guide = Guide.find(2)
    assert !@guide.is_published?
    assert @guide.owner?(users(:arthur))
    get :show, :id => 2
    #XXX: this sucks
#    assert_response :success
#    assert flash[:notice]
  end

  def test_new
    assert !users(:seth).guide_in_progress
    num_guides = Guide.count
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'

    assert_equal num_guides, Guide.count

    login_as :seth
    assert !users(:seth).guide_in_progress
    get :new

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert_equal num_guides + 1, Guide.count
    current_guide = @controller.send(:current_user).guide_in_progress
    assert_not_nil current_guide
    assert current_guide.is_a?(Guide)
  end

  def test_create
    login_as :quentin
    num_guides = Guide.count

    post :create, :guide => {:name => 'test create name', :date => Time.now, :description => 'guide description', :city => 'guide city', :state => 'guide state', :user_id => 1, :permalink => '', :image => nil}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guides + 1, Guide.count

    @guide = Guide.find(:first, :conditions => "name = 'test create name'")
    assert @guide.permalink
    assert_equal @guide.permalink, 'test_create_name'
  end

  def test_edit
    get :edit, :id => 3
    assert_redirected_to :controller => 'account', :action => 'login'
    login_as :quentin

    get :edit, :id => 3

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  def test_edit_past
    login_as :quentin
    get :edit, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  def test_update
    post :update, :id => 3
    assert_redirected_to :controller => 'account', :action => 'login'

    login_as :quentin
    post :update, :id => 3, :guide => { :name => 'updated' }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 3
  end

  def test_update_past
    login_as :quentin
    get :edit, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  def test_destroy
    assert_not_nil Guide.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'

    login_as :quentin
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Guide.find(1)
    }
  end

  def test_reorder
    @guide = Guide.new(:name => 'reorder test', :date => Time.now, :city => 'san francisco', :state => 'CA', :user_id => users(:quentin).id)
    @guide.contests << Contest.find(7,8,9)
    assert @guide.save
    assert_equal Contest.find(7).position, 1
    assert_equal Contest.find(8).position, 2
    assert_equal Contest.find(9).position, 3

    login_as :quentin
    post :order, :id => @guide.id, :contests => ["8","9","7"]
    assert_equal Contest.find(8).position, 1
    assert_equal Contest.find(9).position, 2
    assert_equal Contest.find(7).position, 3
  end

  def test_save_as_draft
    g = Guide.new(:name => 'draftable', :date => Time.now, :city => 'san francisco', :state => 'CA', :status => Guide::PUBLISHED, :user_id => users(:quentin).id)
    assert g.save
    assert g.is_published?

    login_as :quentin
    post :update, :id => g.id, :commit => 'Unpublish'
    assert_response :redirect
    assert_redirected_to :action => 'show'
    updated = Guide.find(g.id)
    assert !updated.is_published?

    post :update, :id => g.id, :status => 'Edit'
    updated_again = Guide.find(g.id)
    assert !updated_again.is_published?
  end

  def test_should_send_request_for_approval
    g = Guide.new(:name => 'c3ish', :date => Time.now, :city => 'sf', :state => 'CA', :user_id => users(:quentin).id)
    g.publish
    assert g.save
    assert_equal 1, @emails.length
  end

  def test_send_tell_a_friend
    post :send_message, :id => guides(:sanfrancisco).id, :from => { :name => 'me', :email => 'valid@valid.com' }, :recipients => { :email => 'to@valid.com', :message => 'message' }
    assert_response :redirect
    assert_redirected_to guides(:sanfrancisco).permalink_url
    assert_equal 1, @emails.length
    assert_equal flash[:notice], 'Message sent'
  end


  def test_domain_awareness
    @request.host = APPLICATION_C3_DOMAIN
    login_as :quentin
    post :new
    assert assigns(:guide)
    assert_equal assigns(:guide).legal, Guide::NONPARTISAN
    assert assigns(:guide).c3?
  end
end
