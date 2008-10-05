class GuidePromoter < ActionMailer::Base
  def tell_a_friend(setup)
    @recipients = setup[:recipients]
    @from = setup[:from_email]
    @bcc = 'voterguides@theleague.com'
    @subject = 'check out this voter guide'
    @body[:from_name] = setup[:from_name]
    @body[:message] = setup[:message]
    @body[:url] = "http://#{setup[:host]}#{setup[:guide].permalink_url}"
  end

  def approval_request(setup)
    @recipients = "voterguides@theleague.com"
    @from = "voterguides@theleague.com"
    @subject = 'c3 guide approval request'
    @send_on = Time.now
    @body[:guide] = setup[:guide]
    @body[:url] = "http://#{APPLICATION_C3_DOMAIN}#{setup[:guide].permalink_url}"
  end

  def change_notification(guide)
    @recipients = 'voterguides@theleague.com'
    @from = 'voterguides@theleague.com'
    @subject = 'changed c3 guide'
    @send_on = Time.now
    @body[:guide] = guide
  end

  def join_notification(guide, user)
  	@recipients = 'voterguides@theleague.com'
	@from = 'voterguides@theleague.com'
	@subject = "[voterguides] #{user.firstname} joined '#{guide.name}' bloc"
	@body[:guide] = guide
	@body[:user] = user
  end

  def publish_notification(guide)
  	@recipients = 'voterguides@theleague.com'
	@from = 'voterguides@theleague.com'
	@subject = "[voterguides] #{guide.user.login} published #{guide.name}"
	@body[:guide] = guide
  end
end
