class Contests::BaseController < ApplicationController
  before_filter :login_required

  def authorized?
    return true if current_user.is_admin?
    @contest ||= Contest.find(params[:id]) if params[:id]
    @guide = @contest.guide if @contest
    @guide ||= Guide.find(params[:guide_id]) if params[:guide_id]
    @guide ||= Guide.find(params[:contest][:guide_id]) if params[:contest] && params[:contest][:guide_id]
    unless @guide && @guide.owner?(current_user)
      flash[:error] = 'Permission Denied'
      return false
    end
    true
  end

  def new
    if request.xhr?
      if request.post?
        @contest ||= Contest.create(params[:contest])
        unless @contest.valid?
          render :update do |page|
            page.replace_html 'contest-edit-window', :file => "contests/candidate/edit_window"
          end
          return
        end
        if params[:choice]
          @choice ||= Choice.new(params[:choice])
          @choice.contest = @contest
          unless @choice.save
            render :update do |page|
              page.replace_html 'contest-edit-window', :file => "contests/candidate/edit_window"
            end
            return
          end
          @contest.choices << @choice
        end
        update_page_after_create
      else
        @contest ||= Contest.new
        @contest.guide_id = params[:guide_id]
        @choice ||= Choice.new(:contest => @contest)
        render :update do |page|
          page.replace_html 'contest-edit-window', :file => "contests/#{@contest.class.to_s.downcase}/edit_window"
          page << "document.getElementById('contest-edit-window').style.visibility = 'visible'"
          page.show('contest-edit-window')
#          page.update_page_new_form(@contest, @choice)
        end
      end
    end
  end

  def edit
    @contest ||= Contest.find(params[:id])
    @guide = @contest.guide
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id]
    if request.post?
      render :update do |page|
        if ( params[:contest] && !@contest.update_attributes(params[:contest]) ) ||
           ( @choice && !@choice.update_attributes(params[:choice]) )
          page.replace_html 'contest-edit-window', :file => "contests/#{@contest.class.to_s.downcase}/edit_window"
        else
          page.replace "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
          page.sortable 'contests', :complete => visual_effect(:highlight, 'contests'), :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
          page.hide('contest-edit-window') if @contest.is_a?(Referendum)
        end
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

  def validate
    @contest = Contest.find(params[:id])
    @valid = @contest.valid? && (@contest.guide.c3? ? @contest.choices.size > 1 : true) 
    if @valid
      render :update do |page|
        page.hide 'contest-edit-window'
        page.visual_effect(:appear, "contest_#{@contest.id}", { :duration => '1.0' })
        page.replace_html 'contest-done-button'
        page.replace_html 'contest-done-button', link_to_remote( 'done', page.hide('contest-edit-window') )
      end
    else
      @contest.errors.add_to_base 'Candidate comparisons require at least the candidates from the major parties' if @contest.guide.c3? && @contest.choices.size < 2
      render :update do |page|
        page.replace_html 'contest-messages', :partial => "contests/candidate/errors", :locals => { :contest => @contest }
      end
    end
  end
end
