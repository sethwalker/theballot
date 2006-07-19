require File.dirname(__FILE__) + '/../test_helper'

class EndorsementTest < Test::Unit::TestCase
  fixtures :endorsements

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_saves_drafts
    guide = Guide.new
    g_draft = guide.save_draft

    endorsement = Endorsement.new
    endorsement.guide = guide
    e_draft = endorsement.save_draft

    e_retrieve = Endorsement::Draft.find_new(:first)
    assert_equal e_retrieve.guide_id, g_draft.id
  end
end
