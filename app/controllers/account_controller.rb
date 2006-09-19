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
      @user.current_domain = @request.host
      @user.save
      flash[:notice] = "A password reset link has been sent to your email address.  Check your email and then login below."
      redirect_to(:action => 'login')
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
    flash.keep :notice
    redirect_to(:action => 'login') and return unless logged_in?
    if params[:id] && (params[:id] == current_user.id || current_user.is_admin?)
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    if c3?
      Guide.with_exclusive_scope(:find => { :conditions => "(legal IS NULL OR legal = '#{Guide::C3}') AND user_id = #{current_user.id}" }) do
        @num_partisan_guides = Guide.count
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @avatar = @user.avatar
    return false unless @user == current_user || current_user.admin?
    if request.post?
      @avatar = @user.build_avatar(:uploaded_data => params[:uploaded_avatar]) if params[:uploaded_avatar].size != 0
      render :action => 'edit' and return unless @user.update_attributes(params[:user])
      flash[:notice] = 'Successfully upated profile'
      redirect_to :action => 'profile' and return
    end
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
    else
      flash[:error] = "Could not login"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.signup_domain = @request.host
    @avatar = @user.build_avatar(:uploaded_data => params[:uploaded_avatar]) if params[:uploaded_avatar] && params[:uploaded_avatar].size != 0
    if @user.save
      flash[:notice] = "Thanks for signing up.  We're shootin' you an email right now.  Just click on the link in the email to activate your account and you'll be up and running."
      redirect_to :action => 'profile'
    end
  end
  
  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/')
  end
end
