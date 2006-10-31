class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def admin
    @users = User.find(:all)
  end

end
