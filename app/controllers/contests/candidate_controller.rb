class Contests::CandidateController < Contests::BaseController
  def new
    if request.post?
      if params[:id]
        @contest = Candidate.find(params[:id])
        @contest.update_attributes(params[:contest]) if params[:contest]
      else
        @contest = Candidate.create(params[:contest])
        @recently_created_contest = true
      end
    else
      if params[:id]
        @contest = Candidate.find(params[:id])
      else
        @contest = Candidate.new
      end
    end
    super
  end

  def add
    @choice = Choice.new
    edit
  end

  def edit
    return unless params[:id]
    @contest ||= Contest.find(params[:id])
    @choice ||= Choice.find(params[:choice_id]) if params[:choice_id]
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id]
    @guide = @contest.guide
    if request.post?
      @contest.update_attributes(params[:contest]) if params[:contest]
      @choice.update_attributes(params[:choice].merge(:contest => @contest)) if params[:choice]
      render :update do |page|
        page.replace_html 'contest-edit-window-left', :partial => "contests/candidate/preview", :locals => { :contest => @contest }
        page.replace_html 'contest-edit-window-right', :partial => "contests/candidate/edit", :locals => { :contest => @contest, :choice => Choice.new(:contest => @contest) }
        page.replace_html "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
        page['choice_name'].value=''
        page['choice_description'].value=''
        page['choice_selection'].value=Choice::NO_ENDORSEMENT unless @c3
      end
    else
      render :update do |page|
        page.update_page_new_form(@contest, @choice)
      end
    end
  end

  def update_page_after_create
    @choice = Choice.new(:contest => @contest)
    render :update do |page|
      page.update_page_new_form(@contest, @choice)
      if @recently_created_contest
        page.insert_html :bottom, 'contests', :partial => 'contests/show', :locals => { :contest => @contest, :hidden => true }
      elsif @contest.id
        page.replace "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest, :hidden => true }
      end
      page.sortable 'contests', :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
      page.replace_html 'contest-done-button', link_to_function( 'done', "document.getElementById('contest-edit-window').style.visibility='hidden';" + visual_effect(:appear, "contest_#{@contest.id}", { :duration => '1.0' }))
    end
  end
end
