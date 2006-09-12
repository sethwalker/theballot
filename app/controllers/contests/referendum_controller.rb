class Contests::ReferendumController < Contests::BaseController
  def new
    if request.post?
      @contest = Referendum.create(params[:contest])
    else
      @contest = Referendum.new
    end
    super
  end

  def edit
    @contest = Referendum.find(params[:id])
    @choice = @contest.choice || Choice.create(:contest => @contest)
    super
  end

  def update_page_after_create
    render :update do |page|
      page.insert_html :bottom, 'contests', :partial => 'contests/show', :locals => { :contest => @contest }
      page.sortable 'contests', :complete => visual_effect(:highlight, 'contests'), :url => { :controller => 'guides', :action => 'order', :id => @contest.guide.id }
      page.hide 'contest-edit-window'
      page.insert_html :bottom, 'debug-messages', 'created contest: ' + @contest.inspect if current_user.developer?
    end
  end
end
