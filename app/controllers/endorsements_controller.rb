class EndorsementsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @endorsement_pages, @endorsements = paginate :endorsements, :per_page => 10
  end

  def show
    @endorsement = Endorsement.find(params[:id])
  end

  def new
    @endorsement = Endorsement.new
  end

  def create
    @endorsement = Endorsement.new(params[:endorsement])
    if @endorsement.save
      flash[:notice] = 'Endorsement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @endorsement = Endorsement.find(params[:id])
  end

  def update
    @endorsement = Endorsement.find(params[:id])
    if @endorsement.update_attributes(params[:endorsement])
      flash[:notice] = 'Endorsement was successfully updated.'
      redirect_to :action => 'show', :id => @endorsement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Endorsement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
