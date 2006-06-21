class GuidesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update ]

  def authorize?(user)
    if ['new', 'create'].include?(action_name)
      return false unless logged_in?
    end
    if ['edit', 'update'].include?(action_name)
      @guide = Guide.find(params[:id])
      return false unless @guide.owner == current_user
    end
  end

  # end new stuff

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @guide_pages, @guides = paginate :guides, :per_page => 10
  end

  def show
    @guide = Guide.find(params[:id], :include => :endorsements)
  end

  def new
    @guide = Guide.new
  end

  def create
    @guide = Guide.new(params[:guide])
    params[:endorsements].each do |num, e|
      endorsement = Endorsement.new(e)
      @guide.endorsements << endorsement
    end
    if @guide.save
      flash[:notice] = 'Guide was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    @guide = Guide.find(params[:id])
    if @guide.update_attributes(params[:guide])
      params[:endorsements].each do |num, e|
        endorsement = Endorsement.new(e)
        @guide.endorsements << endorsement
      end
      flash[:notice] = 'Guide was successfully updated.'
      redirect_to :action => 'show', :id => @guide
    else
      render :action => 'edit'
    end
  end

  def destroy
    Guide.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def add_endorsement
  end
end
