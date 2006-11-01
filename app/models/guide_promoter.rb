class GuidePromoter < ActionMailer::Base
  def tell_a_friend(setup)
    @recipients = setup[:recipients]
    @from = setup[:from_email]
    @bcc = 'sam@indyvoter.org'
    @subject = 'check out this voter guide'
    @body[:from_name] = setup[:from_name]
    @body[:message] = setup[:message]
    @body[:url] = "http://#{setup[:host]}#{setup[:guide].permalink_url}"
  end

  def approval_request(setup)
    @recipients = "sam@indyvoter.org, seth@indyvoter.org"
    @from = "voterguides@indyvoter.org"
    @subject = 'c3 guide approval request'
    @send_on = Time.now
    @body[:guide] = setup[:guide]
    @body[:url] = "http://#{APPLICATION_C3_DOMAIN}#{setup[:guide].permalink_url}"
  end

  def change_notification(guide)
    @recipients = 'sam@indyvoter.org, seth@indyvoter.org'
    @from = 'voterguides@indyvoter.org'
    @subject = 'changed c3 guide'
    @send_on = Time.now
    @body[:guide] = guide
  end

  def join_notification(guide, user)
  	@recipients = 'sam@indyvoter.org'
	@from = 'voterguides@indyvoter.org'
	@subject = "[voterguides] #{user.firstname} joined the bloc for guide {guide.name}"
	@body[:guide] = guide
	@body[:user] = user
  end

  def publish_notification(guide)
  	@recipients = 'sam@indyvoter.org'
	@from = 'voterguides@indyvoter.org'
	@subject = "[voterguides] #{guide.user.firstname} published guide #{guide.id}"
	@body[:guide] = guide
  end
end
