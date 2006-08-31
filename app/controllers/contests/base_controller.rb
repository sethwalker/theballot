class Contests::BaseController < ApplicationController
  before_filter :login_required

  def authorized?
    return true if current_user.is_admin?
    @contest ||= Contest.find(params[:id])
    unless @contest.guide.owner?(current_user)
      flash[:error] = 'Permission Denied'
      return false
    end
  end

  def new
    if request.xhr?
      if request.post?
        @contest ||= Contest.create(params[:contest])
        render :action => 'errors' and return unless @contest.valid?
        if params[:choice]
          @choice ||= @contest.choices.build(params[:choice])
          @choice.save
        end
        update_page_after_create
      else
        @contest ||= Contest.new
        @contest.guide_id = params[:guide_id]
        @choice ||= Choice.new(:contest => @contest)
        render :update do |page|
          page.update_page_new_form(@contest, @choice)
        end
      end
    end
  end

  def edit
    @contest ||= Contest.find(params[:id])
    @guide = @contest.guide
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id]
    if request.post?
      @contest.update_attributes(params[:contest]) if params[:contest]
      @choice.update_attributes(params[:choice]) if @choice
      render :update do |page|
        page.replace "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
        page.sortable 'contests', :complete => visual_effect(:highlight, 'contests'), :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
      end
    else
      render :update do |page|
        page.update_page_new_form(@contest, @choice)
      end
    end
  end

  def destroy
    @contest ||= Contest.find(params[:id])
    @contest.destroy
    render :update do |page|
      page.remove "contest_#{params[:id]}"
    end
  end

  def order
    @contest = Contest.find(params[:id])
    @order = params["contest_#{ @contest.id }_choices"]
    return unless @contest && @order
    @contest.choices.each do |choice|
      choice.position = @order.index(choice.id.to_s) + 1
      choice.save
    end
    render(:nothing => true)
  end
  
  def errors
  end
end
