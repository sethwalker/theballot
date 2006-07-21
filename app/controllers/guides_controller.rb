class GuidesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update ]
  before_filter :check_date, :only => [ :edit, :update ]

#  in_place_edit_for :name, :city

  def check_date
    @guide = Guide.find(params[:id])
    if @guide.date.to_date < Time.now.to_date
      flash[:error] = 'Guides cannot be edited after the election has passed' 
      redirect_to :action => 'show', :id => @guide
    end
  end

  def authorized?
    if ['edit', 'update'].include?(action_name)
      @guide = Guide.find(params[:id])
      unless @guide.owner?(current_user)
        flash[:error] = 'Permission Denied'
        return false 
      end
    end
    true
  end

  def access_denied
    return super unless logged_in?
    redirect_to :action => 'show', :id => params[:id]
  end

  # end new stuff

  def xml
    @guide = Guide.find(params[:id])
    render :xml => @guide.to_xml(:include => :endorsements)
  end
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    conditions = "status = '#{Guide::PUBLISHED}'"
    conditions << " AND date >= '#{Time.now.to_s(:db)}'"
    conditions << " AND state = '#{params[:state]}'" if params[:state]
    conditions << " AND owner_id = '#{params[:author]}'" if params[:author]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions
  end

  def archive
    conditions = "status = '#{Guide::PUBLISHED}'"
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
    if !@guide.is_published?
      if logged_in? && @guide.owner?(current_user)
        flash[:notice] = 'you are viewing this guide in preview mode'
      else
        not_found
      end
    end
    if !@guide.theme.nil?
      template = Liquid::Template.parse(Theme.find(@guide.theme.id).markup)
      @rendered = template.render('guide' => @guide, 'endorsements' => @guide.endorsements)
    end
  end

  def not_found
    flash[:error] = 'Guide not found'
    redirect_to :action => :list
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
    if 'Publish' == params[:status]
      @guide.publish
    else
      @guide.unpublish
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
    @endorsement = Endorsement.new(params[:endorsement])
    if(params[:id])
      @guide = Guide.find(params[:id])
      @guide.endorsements << @endorsement
      @guide.save
    end
  end

  def update_endorsements
  end

  def order
    @guide = Guide.find(params[:id])
    return unless params[:endorsements] && params[:endorsements].size > 1
    @guide.endorsements.each do |e|
      e.position = params[:endorsements].index(e.id.to_s) + 1
      e.save
    end
  end
end
