class Contests::ReferendumController < Contests::BaseController
  def new
    @contest = Referendum.new
  end

  def create
    @contest = Referendum.create(params[:contest])
    super
  end

  def update
    @contest = Referendum.find(params[:id])
    @choice = @contest.choice || Choice.create(:contest => @contest)
    super
  end
end
