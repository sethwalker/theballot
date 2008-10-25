class GuidePromoter < ActionMailer::Base
  def tell_a_friend(setup)
    @recipients = setup[:recipients]
    @from = setup[:from_email]
    @bcc = TheBallot::ADMIN_EMAIL
    @subject = 'check out this voter guide'
    @body[:from_name] = setup[:from_name]
    @body[:message] = setup[:message]
    @body[:url] = "http://#{setup[:host]}#{setup[:guide].permalink_url}"
  end

  def approval_request(setup)
    @recipients = TheBallot::ADMIN_EMAIL
    @from = TheBallot::SYSTEM_FROM_EMAIL
    @subject = 'c3 guide approval request'
    @send_on = Time.now
    @body[:guide] = setup[:guide]
    @body[:url] = "http://#{APPLICATION_C3_DOMAIN}#{setup[:guide].permalink_url}"
  end

  def change_notification(guide)
    @recipients = TheBallot::ADMIN_EMAIL
    @from = TheBallot::SYSTEM_FROM_EMAIL
    @subject = 'changed c3 guide'
    @send_on = Time.now
    @body[:guide] = guide
  end

  def join_notification(guide, user)
  	@bcc = TheBallot::ADMIN_EMAIL
  	@recipients = guide.user.email
	@from = TheBallot::SYSTEM_FROM_EMAIL
	@subject = "[theballot.org] #{user.login} joined '#{guide.name}'"
	@body[:guide] = guide
	@body[:user] = user
  end

  def publish_notification(guide)
  	@recipients = TheBallot::ADMIN_EMAIL
	@from = TheBallot::SYSTEM_FROM_EMAIL
	@subject = "[voterguides] #{guide.user.login} published #{guide.name}"
	@body[:guide] = guide
  end
  
  def comment_notification(guide, user)
  	@bcc = TheBallot::ADMIN_EMAIL
  	@recipients = guide.user.email
	@from = TheBallot::SYSTEM_FROM_EMAIL
	@subject = "[theballot.org] #{user.login} commented on '#{guide.name}'"
	@body[:guide] = guide
	@body[:user] = user
  end
end
