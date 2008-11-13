require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GuideSweeper do
  it "guide save expires index" do
    GuideSweeper.instance.should_receive(:expire_page)
    new_guide.save!
  end
  it "comment save expires index" do
    GuideSweeper.instance.should_receive(:expire_page)
    new_comment.save!
  end
end
