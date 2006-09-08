# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable

  before_filter :set_legal
  filter_parameter_logging "password"

  meantime_filter :scope_guides_by_site
  meantime_filter :scope_approved_guides

  def scope_approved_guides
    if logged_in?
      return yield if current_user.admin?
      conditions = "(legal IS NULL OR NOT legal = '#{Guide::C3}') OR (legal = '#{Guide::C3}' AND guides.user_id = #{current_user.id}) OR (legal = '#{Guide::C3}' AND approved_at IS NOT NULL)"
    else
      conditions = "approved_at IS NOT NULL OR (legal IS NULL OR NOT legal = '#{Guide::C3}')"
    end
    Guide.with_scope({
      :find => { :conditions => conditions }
    }) { yield }
  end

  def scope_guides_by_site
    if c3?
      Guide.with_scope({
        :find => { :conditions => "legal = '#{Guide::C3}'" },
        :create => { :legal => Guide::C3 }
      }) { yield }
    else
      yield
    end
  end


  def set_legal
    c3?
    true
  end

  def c3?
    @c3 = (@request.host == APPLICATION_C3_DOMAIN)
  end

  def is_c3
    render :text => c3?.to_s
  end
end
