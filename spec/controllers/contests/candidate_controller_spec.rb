require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contests::CandidateController do
  fixtures :users, :guides, :contests

  def setup
    @controller = Contests::CandidateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_create
    g = guides(:no_contests)
    assert g.contests.empty?
    xhr :post, :new, :contest => { :name => 'test create candidate contest', :guide_id => guides(:no_contests).id }
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'signup'

    num_candidate_contests = Candidate.count
    login_as :quentin
    xhr :post, :new, :contest => { :name => 'test create candidate contest', :guide_id => guides(:no_contests).id }
    assert_response :success
    assert_equal Candidate.count, num_candidate_contests + 1
    @guide = Guide.find(guides(:no_contests).id)
    assert_equal @guide.contests.first.name, 'test create candidate contest'
    assert_equal @guide.contests.count, 1
  end
end
