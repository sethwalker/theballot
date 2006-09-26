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
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id] && !params[:choice][:id].empty?
    @choice ||= Choice.new(:contest => @contest)
    @guide = @contest.guide
    if request.post?
      @contest.update_attributes(params[:contest]) if params[:contest]
      if params[:choice]
        @saved_choice = @choice.update_attributes(params[:choice].merge(:contest => @contest))
      end
      render :update do |page|
        if @saved_choice
          @choice = Choice.new
          page.replace_html 'contest-edit-window', :file => "contests/candidate/edit_window"
          page.replace "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
          page.sortable 'contests', :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
        else
          page.replace_html 'contest-edit-window', :file => "contests/candidate/edit_window"
        end
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
    end
  end
end
