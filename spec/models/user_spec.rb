require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :users

  it "should be valid" do
    create_user.should be_valid
  end

  it "should create user" do
    lambda {
      create_user
    }.should change(User, :count)
  end

  def test_should_require_login
    u = new_user(:login => nil)
    lambda {
      u.save
    }.should_not change(User, :count)
    assert u.errors.on(:username)
  end

  def test_should_require_password
    lambda {
      u = new_user(:password => nil)
      u.save
      assert u.errors.on(:password)
    }.should_not change(User, :count)
  end

  def test_should_require_password_confirmation
    lambda {
      u = new_user(:password_confirmation => nil)
      u.save
      assert u.errors.on(:password_confirmation)
    }.should_not change(User, :count)
  end

  def test_should_require_email
    u = new_user(:email => nil)
    lambda {
      u.save
    }.should_not change(User, :count)
    assert u.errors.on(:email)
  end

  def test_should_reset_password
    pending
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    pending
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    assert_equal users(:quentin), User.authenticate('quentin2@example.com', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'test')
  end
end
