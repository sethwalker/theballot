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
    #assert !@controller.send(:logged_in?)
#    login_as :quentin
#    @request.session[:user] = 1
#    assert @controller.send(:logged_in?)
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
    #XXX: this sucks
#    assert_response :success
#    assert flash[:notice]
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

    post :create, :guide => {:name => 'test create name', :date => Time.now, :description => 'guide description', :city => 'guide city', :state => 'guide state', :user_id => 1, :permalink => ''}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guides + 1, Guide.count

    @guide = Guide.find(:first, :conditions => "name = 'test create name'")
    assert @guide.permalink
    assert_equal @guide.permalink, 'test_create_name'
  end

  def test_create_with_endorsements
    authorize_as :quentin
    post :create, :guide => { :name => 'test create with endorsements', :date => Time.now, :endorsements => [ Endorsement.new(:contest => 'first'), Endorsement.new(:contest => 'second'), Endorsement.new(:contest => 'third') ] }
    g = Guide.find_by_name('test create with endorsements')
    assert g
    assert_equal g.endorsements.size, 3
  end

  def test_invalid_create_with_endorsments
    name = 'test invalid create with endorsements'
    authorize_as :quentin
    post :create, :guide => { :name => name }, :endorsements => { "0" => { :contest => 'first' }, "1" => { :contest => 'second' }, "2" => { :contest => 'third'} }

    assert !Guide.find_by_name(name)
    assert assigns('guide')
    assert_equal assigns('guide').endorsements.size, 3
    assert_equal assigns('guide').endorsements.sort_by {|e| e.position}.first.contest, 'first'
  end

  def test_invalid_create_after_reorder
    authorize_as :quentin
    post :create, :guide => { :name => 'invalid with reorder' }, :endorsements => { "0" => { :contest => 'first' }, "1" => { :contest => 'second' }, "2" => { :contest => 'third'} }, :order => '1,0,2'

    assert assigns('guide')
    assert !assigns('guide').valid?
    assert_equal assigns('guide').endorsements.size, 3
    assert_equal assigns('guide').endorsements.sort_by {|e| e.position}.first.contest, 'second'
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
    post :update, :id => 3, :guide => { :name => 'updated' }
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

  def test_order_on_new
    authorize_as :quentin
    
    post :order, :endorsements => [8,9,7]
    assert_tag :tag => 'input',
      :attributes => { :type => 'hidden', :name => 'order' }
  end

  def test_reorder
    @guide = Guide.new(:name => 'reorder test', :date => Time.now)
    @guide.endorsements << Endorsement.find(7,8,9)
    assert @guide.save
    assert_equal Endorsement.find(7).position, 1
    assert_equal Endorsement.find(8).position, 2
    assert_equal Endorsement.find(9).position, 3

    post :order, :id => @guide.id, :endorsements => ["8","9","7"]
    assert_equal Endorsement.find(8).position, 1
    assert_equal Endorsement.find(9).position, 2
    assert_equal Endorsement.find(7).position, 3
  end

  def test_save_as_draft
    g = Guide.new(:name => 'draftable', :date => Time.now, :status => Guide::PUBLISHED, :user_id => users(:quentin).id)
    assert g.save
    assert g.is_published?

    authorize_as :quentin
    post :update, :id => g.id, :commit => 'Unpublish'
    assert_response :redirect
    assert_redirected_to :action => 'show'
    updated = Guide.find(g.id)
    assert !updated.is_published?

    post :update, :id => g.id, :status => 'Edit'
    updated_again = Guide.find(g.id)
    assert !updated_again.is_published?
  end

  def test_add_endorsement
    g = guides(:no_endorsements)
    assert g.endorsements.empty?
    count = Endorsement.count
    post :add_endorsement, :id => g.id, :endorsement => { :contest => 'assembly', :candidate => 'janet' }
    assert_response :success
    assert_template '_endorsement'
    assert_equal Endorsement.count, count + 1
    assert Endorsement.find_by_guide_id(g.id)
    @guide = Guide.find(g.id)
    assert_equal @guide.endorsements.first.contest, 'assembly'
    assert_equal @guide.endorsements.count, 1
  end

end
