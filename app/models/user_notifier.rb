class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{user.signup_domain}/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @recipients  = TheBallot::ADMIN_EMAIL
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
    @recipients = TheBallot::ADMIN_EMAIL
    @from = TheBallot::SYSTEM_FROM_EMAIL
    @subject = "[THEBALLOT] - failed login by " + email
    @body[:email] = email
    @body[:user] = User.find_by_email(email)
  end

  def login_successful(email)
    @recipients = TheBallot::ADMIN_EMAIL
    @from = TheBallot::SYSTEM_FROM_EMAIL
    @subject = "[THEBALLOT] - successful login by " + email
    @body[:email] = email
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = TheBallot::SYSTEM_FROM_EMAIL
    @subject     = "[voterguides] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
