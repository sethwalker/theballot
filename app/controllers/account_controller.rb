class AccountController < ApplicationController

  def activate
    if params[:activation_code]
      @user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].nil?
      if @user and @user.activate
        self.current_user = @user
        redirect_back_or_default(:controller => '/account', :action => 'index')
        flash[:notice] = "Your account has been activated." 
      else
        flash[:error] = "Unable to activate the account.  Did you provide the correct information?" 
      end
    else
      flash.clear
    end
  end  

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
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
