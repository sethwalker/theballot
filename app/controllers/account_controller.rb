class AccountController < ApplicationController
  observer :user_observer

  def activate
    @user = User.find_by_activation_code(params[:id]) unless params[:id].nil?
    if @user and @user.activate
      self.current_user = @user
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Your account has been activated." 
    else
      flash[:error] = "Unable to activate the account.  Did you provide the correct information?" 
    end
  end  

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
    @user = current_user
  end

  def profile
    if params[:id] && (params[:id] == current_user.id || current_user.is_admin?)
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    render :action => 'index'
  end

  def update
  end

  def remove_admin
    return unless current_user.is_admin?
    @user = User.find(params[:id])
    @user.roles.delete(Role.find_by_title('admin'))
    render :text => 'No', :layout => false
  end

  def add_admin
    @user = User.find(params[:id])
    @user.roles << Role.find_by_title('admin')
    @user.save
    render :text => 'Yes', :layout => false
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    if @user.save
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Thanks for signing up!"
    end
  end
  
  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
end
