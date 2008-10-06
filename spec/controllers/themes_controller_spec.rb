require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ThemesController do
  fixtures :themes

  before(:all) do
    @user = create_user
    @user.roles << Role.find_or_create_by_title('admin')
  end

  before do
    request.session[:user] = @user.id
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

    assert_not_nil assigns(:themes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:theme)
    assert assigns(:theme).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:theme)
  end

  def test_create
    num_themes = Theme.count

    post :create, :theme => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_themes + 1, Theme.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:theme)
    assert assigns(:theme).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Theme.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Theme.find(1)
    }
  end
end
