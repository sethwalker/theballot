require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GuidePromoter do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :guides
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  it "delivers approval request" do
    guides(:nonpartisan).should be_c3
    guides(:nonpartisan).publish.should_not be_false
    guides(:nonpartisan).save.should be_true
    ActionMailer::Base.deliveries.size.should == 2

    guides(:partisan).should_not be_c3
    guides(:partisan).publish.should_not be_false
    guides(:partisan).save.should be_true
    ActionMailer::Base.deliveries.size.should == 3
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/guide_promoter/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
