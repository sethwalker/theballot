class GuidePromoter < ActionMailer::Base
  def tell_a_friend(setup)
    @recipients = setup[:recipients]
    @from = "voterguides@indyvoter.org"
    @subject = 'Check out this dope guide'
    @send_on = Time.now
    @body[:guide] = setup[:guide]
    @body[:user] = setup[:user]
    @body[:message] = setup[:message]
    @body[:url] = "http://#{APPLICATION_HOST_NAME}#{setup[:guide].permalink_url}"
  end
end
