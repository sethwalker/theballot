# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable

  before_filter :set_legal
  before_filter :set_cache_root
  filter_parameter_logging "password"

  around_filter :scope_guides_by_site

  def set_cache_root
    self.class.page_cache_directory = File.join([RAILS_ROOT, 'public', 'cache', request.host])
  end

  def scope_guides_by_site
    if c3?
      Guide.with_c3 do
        yield
      end
    else
      yield
    end
  end

  def set_legal
    c3?
    true
  end

  def c3?
    @c3 = (request.host == APPLICATION_C3_DOMAIN)
  end

  def is_c3
    render :text => c3?.to_s
  end

  def render_404
    respond_to do |type|
      type.html { render :file => 'shared/404', :status => "404 Not Found", :use_full_path => true, :layout => true }
      type.all  { render :nothing => true, :status => "404 Not Found" }
    end
  end

  def render_500
    respond_to do |type|
      type.html { render :file => 'shared/500', :status => "500 Error", :use_full_path => true, :layout => true }
      type.all  { render :nothing => true, :status => "500 Error" }
    end
  end
end
