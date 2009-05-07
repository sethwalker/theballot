class TellAFriend

  include Rakismet::ModelExtensions
  has_rakismet

  def initialize(params, guide, user, host, permanent_url)
    @params = params
    @guide  = guide
    @user   = user
    @host   = host
    @permalink_url = permanent_url
  end

  def from_name
    @user ? "#{user.firstname} #{user.lastname}" : @params[:from][:name]
  end

  def from_email
    @user ? @user.email : @params[:from][:email]
  end

  #author        : name submitted with the comment
  def author
    from_name
  end

  #author_url    : URL submitted with the comment
  def author_url
    nil
  end

  #author_email  : email submitted with the comment
  def author_email
    from_email
  end

  #comment_type  : 'comment', 'trackback', 'pingback', or whatever you fancy
  def comment_type
    'comment'
  end

  #content       : the content submitted
  def content
    @params[:recipients][:message]
  end

  #permalink     : the permanent URL for the entry the comment belongs to
  def permalink
    @permalink_url
  end

  def [](param)
    case param
    when :recipients
      @params[:recipients][:email]
    when :from_email
      from_email
    when :guide
      @guide
    when :message
      @params[:recipients][:message]
    when :from_name
      from_name
    when :from_email
      from_email
    when :host
      @host
    else
      raise 'not supported'
    end
  end
end
