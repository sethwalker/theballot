class StylesController < ApplicationController
  before_filter :login_required, :except => [ :show ]
  caches_page :show
  @@page_cache_extension = '.css'

  def authorized?
    return true if current_user.admin?
    flash[:error] = 'Permission Denied'
    false
  end

  layout nil
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @style_pages, @styles = paginate :styles, :per_page => 10
  end

  def show
    headers["Content-Type"] = "text/css; charset=utf-8"
    @style = Style.find(params[:id])
    render :text => @style.stylesheet
  end

  def new
    @style = Style.new
  end

  def create
    @style = Style.new(params[:style])
    if @style.save
      flash[:notice] = 'Style was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @style = Style.find(params[:id])
  end

  def update
    @style = Style.find(params[:id])
    if @style.update_attributes(params[:style])
      expire_page :controller => 'styles', :action => 'show', :id => params[:id]
      flash[:notice] = 'Style was successfully updated.'
      redirect_to :action => 'show', :id => @style
    else
      render :action => 'edit'
    end
  end

  def destroy
    Style.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
