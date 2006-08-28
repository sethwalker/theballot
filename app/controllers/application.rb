# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :set_legal

  def set_legal
    c3?
    true
  end

  def c3?
    @c3 ||= (@request.host == APPLICATION_C3_DOMAIN)
  end

  def is_c3
    render :text => c3?.to_s
  end
end
