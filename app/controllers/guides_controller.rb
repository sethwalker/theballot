class GuidesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update ]

  in_place_edit_for :name, :city

  def authorized?
    if ['edit', 'update'].include?(action_name)
      @guide = Guide.find(params[:id])
      return false unless @guide.owner.id == current_user.id
    end
    true
  end

  def access_denied
    flash[:error] = 'cannot edit guides you did not create'
    redirect_to :action => 'show', :id => params[:id]
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
    conditions = "status = 'Publish'"
    conditions << " AND date >= '#{Time.now.to_s(:db)}'"
    conditions << " AND state = '#{params[:state]}'" if params[:state]
    conditions << " AND owner_id = '#{params[:author]}'" if params[:author]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions
  end

  def archive
    conditions = "status = 'Publish'"
    conditions << " AND date > '#{Time.now.to_s(:db)}'"
    conditions << " AND state = '#{params[:state]}'" if params[:state]
    conditions << " AND owner_id = '#{params[:author]}'" if params[:author]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions
    render :action => 'list'
  end

  def show
    if(params[:year] && params[:month] && params[:day] && params[:permalink])
      Guide.with_scope(:find => { :conditions => ['date = ?', Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i).to_s] } ) do
        @guide = Guide.find_by_permalink(params[:permalink])
      end
    else
      @guide = Guide.find(params[:id], :include => :endorsements)
    end
    if 'Draft' == @guide.status
      redirect_to :action => :list unless @guide.owner_id == current_user.id
      flash[:notice] = 'you are viewing this in preview mode'
    end
    if !@guide.theme.nil?
      template = Liquid::Template.parse(Theme.find(@guide.theme.id).markup)
      @rendered = template.render('guide' => @guide, 'endorsements' => @guide.endorsements)
    end
  end

  def new
    @guide = Guide.new
  end

  def create
    @guide = Guide.new(params[:guide])
    if params.include?('endorsements')
      params[:endorsements].each do |num, e|
        @guide.endorsements.build(e)
      end
    end
    if params.include?('image')
      @guide.build_image(params[:image])
    end
    if params.include?('pdf')
      @guide.build_pdf(params[:pdf])
    end
    @guide.owner_id = current_user.id
    case params[:status]
    when 'Publish'
      @guide.status = 'Publish'
    when 'Save As Draft'
      @guide.status = 'Draft'
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
    return render :action => 'edit' unless @guide.update_attributes(params[:guide])
    if params.include?(:endorsements)
      params[:endorsements].each do |num, e|
        endorsement = @guide.endorsements.find_or_create_by_id(e[:id])
        #maybe: @guide.endorsements.find_or_create(e)
        #endorsement = Endorsement.find(e[:id])
        endorsement.update_attributes(e)
        #@guide.endorsements << endorsement
      end
    end
    if params.include?(:image)
      @guide.image = Image.new(params[:image])
    end
    if params.include?(:pdf)
      @guide.pdf = PDF.new(params[:pdf])
    end
    flash[:notice] = 'Guide was successfully updated.'
    redirect_to :action => 'show', :id => @guide
  end

  def destroy
    Guide.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def add_endorsement
=begin
    Guide::Draft.with_scope(:find => { :conditions => ['owner_id = ?', current_user.id] }) do
      @guide = Guide::Draft.find_new(:first, :conditions => ['owner_id = ?', current_user.id] )
    end
    unless @guide
      g = Guide.new
      g.owner_id = current_user.id
      @guide = guide.save_draft
    end
    @guide.endorsements.build(params[:endorsement])
    e = Endorsement.new(params[:endorsement])
    e.guide_id = @guide.id
    e.save_draft
    @endorsement = e.draft
=end
    @endorsement = Endorsement.new(params[:endorement])
  end

  def update_endorsements
  end

  def order
    return unless params[:endorsements] && params[:endorsements].size > 1
    params[:endorsements].each do |e|
      string = string + Endorsement::Draft.find(e).inspect
    end
    render :text => 'hi'
  end
end
