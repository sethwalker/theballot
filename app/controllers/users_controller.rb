class UsersController < ApplicationController
  before_filter :admin_required, :except => :show

  def show
    @user = User.find(params[:id])
  end

  def admin
    @users = User.find(:all, :include => [:guides])
  end

  def export
    @users = User.find(:all, :include => [:guides])
    doc = FasterCSV.generate do |csv|
      csv << ['login', 'email', 'created_at', 'activated_at', 'street', 'city', 'state', 'postal_code', 'phone', 'signup_domain', 'firstname', 'lastname', 'url', 'about_me', 'avatar_url', 'guides']
      @users.each do |user|
        csv << [user.login, user.email, user.created_at, user.activated_at, user.street, user.city, user.state, user.postal_code, user.phone, user.signup_domain, user.firstname, user.lastname, user.url, user.about_me, user.avatar ? "http://theballot.org/#{user.avatar.public_filename('thumb')}" : nil, user.guides.map {|guide| "http://theballot.org#{guide.permalink_url}" }.join(',')] 
      end
    end
    send_data doc, :type => 'text/csv', :filename => 'theballot.org.users.csv', :disposition => 'attachment'
  end

  private

  def admin_required
    redirect_to login_url unless logged_in? && current_user.is_admin?
  end
end
