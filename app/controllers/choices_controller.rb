class ChoicesController < ApplicationController
  before_filter :login_required

  in_place_edit_for :choice, :selection

  def authorized?
    return true if current_user.is_admin?
    @contest = Contest.find(params[:id])
    unless @contest.guide.owner?(current_user)
      flash[:error] = 'Permission Denied'
      return false
    end
  end

  def edit
    @choice = Choice.find(params[:id])
    render :update do |page|
      page.replace_html 'contest-edit-window-left', :partial => 'guides/referendum_form'
    end
  end
end
