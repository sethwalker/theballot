class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{user.signup_domain}/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @recipients  = "voterguides@theleague.com"
    @subject    += "new account: #{user.email}"
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "http://#{user.current_domain}/account/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'
  end  

  def login_incorrect(email)
    @recipients = "voterguides@theleague.com"
    @from = "voterguides@theleague.com"
    @subject = "[THEBALLOT] - failed login"
    @body[:email] = email
    @body[:user] = User.find_by_email(email)
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "voterguides@theleague.com"
    @subject     = "[voterguides] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
