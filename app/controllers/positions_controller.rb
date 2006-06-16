class PositionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @position_pages, @positions = paginate :positions, :per_page => 10
  end

  def show
    @position = Position.find(params[:id])
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(params[:position])
    if @position.save
      flash[:notice] = 'Position was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @position = Position.find(params[:id])
  end

  def update
    @position = Position.find(params[:id])
    if @position.update_attributes(params[:position])
      flash[:notice] = 'Position was successfully updated.'
      redirect_to :action => 'show', :id => @position
    else
      render :action => 'edit'
    end
  end

  def destroy
    Position.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
