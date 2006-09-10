require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  before_create :make_activation_code

  validates_acceptance_of :tos, :message => "You must agree to these terms of service"

  has_many :guides
  has_many :pledges
  has_many :blocs, :through => :pledges, :source => :guide
  has_many :images
  has_many :attached_pdfs
  has_many :screenshots
  has_one :avatar
  # adding acl_system2 support http://opensvn.csie.org/ezra/rails/plugins/dev/acl_system2/
  has_and_belongs_to_many :roles

  def admin?
    roles.any? {|r| 'admin' == r.title.downcase }
  end

  def is_admin?
    admin?
  end

  def developer?
    roles.any? {|r| 'developer' == r.title.downcase }
  end

  def guide_in_progress(is_c3 = false)
    conditions = []
    conditions << "status IS NULL"
    conditions << "legal = '#{Guide::C3}'" if is_c3
    guides.find(:first, :conditions => conditions.join(' AND '))
  end

  def avatar_thumb
    has_avatar? ? avatar.public_filename('thumb') : 'avatar.jpg'
  end


  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
    #u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def forgot_password
   @forgotten_password = true
   self.make_password_reset_code
  end

  def reset_password
   # First update the password_reset_code before setting the 
   # reset_password flag to avoid duplicate email notifications.
   update_attributes(:password_reset_code => nil)
   @reset_password = true
  end

  def recently_reset_password?
   @reset_password
  end

  def recently_forgot_password?
   @forgotten_password
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  protected
    # If you're going to use activation, uncomment this too
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split('//').sort_by {rand}.join )
    end

    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
