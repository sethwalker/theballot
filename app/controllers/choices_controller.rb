class ChoicesController < ApplicationController
  before_filter :login_required

  in_place_edit_for :choice, :selection

  def authorized?
    return true if current_user.is_admin?
    @choice = Choice.find(params[:id])
    unless @choice.contest.guide.owner?(current_user)
      return false
    end
    true
  end

  def destroy
    @choice ||= Choice.find(params[:id])
    if @choice.destroy
      render :update do |page|
        page.replace "contest_#{@choice.contest.id}", :partial => 'contests/show', :locals => { :contest => @choice.contest }
      end
    end
  end
end
