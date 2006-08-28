class Contests::CandidateController < Contests::BaseController
  def new
    @contest = Candidate.new
  end

  def create
    @contest = Candidate.create(params[:contest])
    super
  end

  def add
    @choice = Choice.new
    edit
  end

  def update
    return unless params[:id]
    @contest ||= Contest.find(params[:id])
    @contest.update_attributes(params[:contest]) if params[:contest]
    @guide = @contest.guide
    @choice ||= Choice.find(params[:choice][:id]) if params[:choice] && params[:choice][:id] && !params[:choice][:id].empty?
    @choice ||= Choice.create(params[:choice].merge(:contest => @contest)) if params[:choice]
    render :update do |page|
      page.replace_html 'contest-edit-window-left', :partial => "contests/candidate/preview", :locals => { :contest => @contest }
      page.replace_html 'contest-edit-window-right', :partial => "contests/candidate/edit", :locals => { :contest => @contest, :choice => Choice.new(:contest => @contest) }
      page.replace_html "contest_#{@contest.id}", :partial => 'contests/show', :locals => { :contest => @contest }
      page['choice_name'].value=''
      page['choice_description'].value=''
      page['choice_selection'].value=Choice::NO_ENDORSEMENT unless @c3
      page.replace_html 'contest-messages', 'updated contest: ' + @contest.inspect if current_user.developer?
    end
  end
end
