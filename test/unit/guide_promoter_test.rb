require File.dirname(__FILE__) + '/../test_helper'
require 'guide_promoter'

class GuidePromoterTest < Test::Unit::TestCase
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

  def test_delivers_approval_request
    assert guides(:nonpartisan).c3?
    assert guides(:nonpartisan).publish
    assert guides(:nonpartisan).save
    assert_equal ActionMailer::Base.deliveries.size, 1

    assert !guides(:partisan).c3?
    assert guides(:partisan).publish
    assert guides(:partisan).save
    assert_equal ActionMailer::Base.deliveries.size, 1
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/guide_promoter/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
