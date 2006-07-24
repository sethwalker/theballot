class EndorsementsController < ApplicationController

  def authorized?
    if ['edit', 'update', 'destroy'].include?(action_name)
      @endorsement = Endorsement.find(params[:id])
      unless @endorsement.guide.owner?(current_user)
        flash[:error] = 'Permission Denied'
        return false
      end
    end
    true
  end

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

  def add
    @endorsement = Endorsement.new(params[:endorsement])
    @index = params[:index].to_i || 0
    @order = params[:current_order] || "#{@index}"
    @order << ",#{@index}" if @index > 0
  end

  def create
    @endorsement = Endorsement.new(params[:endorsement])
    @endorsement.save if @endorsement.guide
  end

  def edit
    @endorsement = Endorsement.find(params[:id])
  end

  def update
    @endorsement = Endorsement.find(params[:id])
    render :nothing => true unless @endorsement.update_attributes(params[:endorsement])
  end

  def destroy
    @endorsement = Endorsement.find(params[:id])
    @endorsement.destroy if @endorsement
    @number = params[:id]
  end

  def remove
    @index = params[:index]
#    @order = params[:current_order].split(',').delete_if {|i| i == @index}.join(',')
  end
end
