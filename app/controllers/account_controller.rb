class AccountController < ApplicationController
  observer :user_observer

  def activate
    @user = User.find_by_activation_code(params[:id]) unless params[:id].nil?
    if @user and @user.activate
      self.current_user = @user
      redirect_back_or_default(:controller => '/account', :action => 'profile')
      flash[:notice] = "Your account has been activated." 
    else
      flash[:error] = "Unable to activate the account.  Did you provide the correct information?" 
    end
  end  

  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "A password reset link has been sent to your email address" 
    else
      flash[:notice] = "Could not find a user with that email address" 
    end
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:id])
    return if @user unless params[:password]
    if (params[:password] == params[:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:password_confirmation]
      current_user.password = params[:password]
      @user.reset_password
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
    else
      flash[:notice] = "Password mismatch" 
    end  
    redirect_back_or_default(:controller => '/account', :action => 'index') 
  end

  def index
    redirect_to(:action => 'signup') and return unless logged_in? || User.count == 0
    redirect_to(:action => 'profile')
  end

  def profile
    redirect_to(:action => 'login') unless logged_in?
    return unless logged_in?
    if params[:id] && (params[:id] == current_user.id || current_user.is_admin?)
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def update
    @user = User.find(params[:id])
    return unless @user == current_user || current_user.admin?
    @avatar = Avatar.create(params[:avatar])
    render :action => 'profile' and return unless @avatar.valid?
    @user.avatar = @avatar
    flash[:notice] = 'Successfully uploaded image'
    redirect_to :action => 'profile'
  end

  def remove_admin
    return unless current_user.is_admin?
    @user = User.find(params[:id])
    @user.roles.delete(Role.find_by_title('admin'))
    render :partial => 'admin_control', :locals => { :user => @user }, :layout => false
  end

  def add_admin
    return unless current_user.is_admin?
    @user = User.find(params[:id])
    @user.roles << Role.find_by_title('admin')
    @user.save
    render :partial => 'admin_control', :locals => { :user => @user }, :layout => false
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:email], params[:password])
    if current_user
      redirect_back_or_default(:controller => '/account', :action => 'profile')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    if @user.save
      redirect_back_or_default(:controller => '/account', :action => 'profile')
      flash[:notice] = "Thanks for signing up!"
    end
  end
  
  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/')
  end
end
