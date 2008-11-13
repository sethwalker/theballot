require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GuidesController do
  fixtures :users

  it "test_index" do
    get :index
    assert_response :success
    assert_template 'index'
  end

  it "test_list" do
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:guides)
  end

  it "test_show" do
    get :show, :id => 3

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  describe "caching" do
    it "caches index" do
      lambda { get :index }.should cache_page('/')
    end
    it "does not cache when logged in" do
      login_as(new_user)
      lambda { get :index }.should_not cache_page('/')
    end
  end

  describe "preview" do
    def act!
      get :show, :id => 2
    end
    it "should be redirect" do
      act!
      response.should be_redirect
    end
    it "should redirect to list" do
      act!
      assert_redirected_to :action => :list
    end
    it "should show error in flash" do
      act!
      flash[:error].should_not be_empty
    end

    describe "when logged in" do
      before do
        login_as(@user = new_user)
        @guide = new_guide(:status => Guide::DRAFT, :user => @user)
        Guide.stub!(:find).with('123').and_return(@guide)
      end

      it "is not published" do
        @guide.should_not be_published
      end

      it "should be owned by user" do
        @guide.owner?(@user).should be_true
      end

      it "should be success" do
        get :show, :id => '123'
        assert_response :success
      end
      it "should have flash notice" do
        get :show, :id => '123'
        assert flash[:notice]
      end
    end
  end

  it "test_new" do
    assert !users(:seth).guide_in_progress
    num_guides = Guide.count
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'signup'

    assert_equal num_guides, Guide.count

    login_as :seth
    assert !users(:seth).guide_in_progress
    get :new

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert_equal num_guides + 1, Guide.count
    current_guide = controller.send(:current_user).guide_in_progress
    assert_not_nil current_guide
    assert current_guide.is_a?(Guide)
  end

  it "test_create" do
    controller.stub!(:login_required).and_return(true)
    num_guides = Guide.count

    post :create, :guide => {:name => 'test create name', :date => Time.now, :description => 'guide description', :city => 'guide city', :state => 'guide state', :user_id => 1, :permalink => '', :image => nil}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guides + 1, Guide.count

    @guide = Guide.find(:first, :conditions => "name = 'test create name'")
    assert @guide.permalink
    assert_equal @guide.permalink, 'test-create-name'
  end

  it "test_edit" do
    get :edit, :id => 3
    assert_redirected_to :controller => 'account', :action => 'signup'
    login_as :quentin

    get :edit, :id => 3

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guide)
    assert assigns(:guide).valid?
  end

  it "test_edit_past" do
    login_as :quentin
    get :edit, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  it "test_update" do
    post :update, :id => 3
    assert_redirected_to :controller => 'account', :action => 'signup'

    login_as :quentin
    post :update, :id => 3, :guide => { :name => 'updated' }
    assert_response :redirect
    assert_redirected_to :controller => 'guides', :action => 'show', :permalink => assigns[:guide].permalink, :year => assigns[:guide].date.year
  end

  it "test_update_past" do
    login_as :quentin
    get :edit, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 4
  end

  it "test_destroy" do
    assert_not_nil Guide.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'signup'

    login_as :quentin
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Guide.find(1)
    }
  end

  it "test_reorder" do
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

  it "test_save_as_draft" do
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

  it "test_send_tell_a_friend" do
    GuidePromoter.should_receive(:deliver_tell_a_friend).and_return(true)
    Guide.should_receive(:find).with('123').and_return(new_guide(:date => Date.new(2008, 11, 4), :permalink => 'sf'))
    post :send_message, :id => '123', :from => { :name => 'me', :email => 'valid@valid.com' }, :recipients => { :email => 'to@valid.com', :message => 'message' }
    assert_response :redirect
    assert_redirected_to '/2008/sf'
    flash[:notices].first.should match(/An email has been sent/)
  end


  it "test_domain_awareness" do
    request.host = APPLICATION_C3_DOMAIN
    login_as :quentin
    post :new
    assert assigns(:guide)
    assert_equal assigns(:guide).legal, Guide::NONPARTISAN
    assert assigns(:guide).c3?
  end
end
