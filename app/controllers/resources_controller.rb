class ResourcesController < ApplicationController
  def create
    breakpoint 'hey there'
    @resource = Resource.create params[:resource]
    render :action => 'new'
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def new
    @resource = Resource.new
  end

  def edit
    @resource = Resource.find(params[:id])
  end
end
