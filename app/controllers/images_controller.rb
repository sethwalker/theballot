class ImagesController < ApplicationController
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def create
    @image = Image.new(params[:image])
    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def list
    @image_pages, @images = paginate :images, :per_page => 10, :conditions => 'ISNULL(parent_id)'
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end
end
