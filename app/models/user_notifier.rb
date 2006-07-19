class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://{@request.env['HTTP_HOST']}/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://{@request.env['HTTP_HOST']}/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "voterguides@{@request.env['SERVER_NAME']}"
    @subject     = "[voterguides] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
