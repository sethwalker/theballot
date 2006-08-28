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
    @contest = Contest.new
  end

  def errors
  end

  def create
    @contest ||= Contest.create(params[:contest])
    render :action => 'errors' and return unless @contest.valid?
    @choice ||= @contest.choices.build(params[:choice])
    @choice.save

    render :update do |page|
      page.insert_html :bottom, 'contests', :partial => 'contests/show', :locals => { :contest => @contest }
      page.sortable 'contests', :complete => visual_effect(:highlight, 'contests'), :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
      page['contest_name'].value=''
      page['choice_description'].value=''
      page['choice_selection'].value=Choice::NO_ENDORSEMENT
      page.replace_html 'contest-messages', 'created contest: ' + @contest.inspect if current_user.developer?
    end
  end

  def edit
    @contest = Contest.find(params[:id])
    @choice ||= Choice.find(params[:choice]) if params[:choice]
    render :update do |page|
      page.replace_html 'contest-edit-window-left', :partial => "contests/#{@contest.class.to_s.downcase}/preview", :locals => { :contest => @contest }
      page.replace_html 'contest-edit-window-right', :partial => "contests/#{@contest.class.to_s.downcase}/edit", :locals => { :contest => @contest, :choice => @choice }
      page << "document.getElementById('contest-edit-window').style.visibility='visible'"
    end
  end

  def update
    return unless params[:id]
    @contest ||= Contest.find(params[:id])
    @contest.update_attributes(params[:contest]) if params[:contest]
    @guide = @contest.guide
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id]
    @choice.update_attributes(params[:choice]) if @choice
    render :update do |page|
      page.replace "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
      page.sortable 'contests', :complete => visual_effect(:highlight, 'contests'), :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
      page.replace_html 'contest-edit-window-left', :partial => "contests/referendum/new", :locals => { :contest => Referendum.new(:guide => @guide), :choice => Choice.new }
      page.replace_html 'contest-edit-window-right', :partial => "contests/candidate/new", :locals => { :contest => Candidate.new(:guide => @guide), :choice => Choice.new }
      page['contest_name'].value=''
      page['choice_name'].value=''
      page['choice_description'].value=''
      page['choice_selection'].value=Choice::NO_ENDORSEMENT
      page.replace_html 'contest-messages', 'updated contest: ' + @contest.inspect if current_user.developer?
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
end
