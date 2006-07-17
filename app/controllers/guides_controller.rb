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
    conditions = "date > '#{Time.now.to_s(:db)}'"
    conditions << " AND state = '#{params[:state]}'" if params[:state]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions
  end

  def archive
    conditions = "date > '#{Time.now.to_s(:db)}'"
    conditions << " AND state = '#{params[:state]}'" if params[:state]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions
    render :action => 'list'
  end

  def show
    @guide = Guide.find(params[:id], :include => :endorsements)
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
        @guide.build_endorsement(e)
      end
    end
    if params.include?('image')
      @guide.build_image(params[:image])
    end
    if params.include?('pdf')
      @guide.build_pdf(params[:pdf])
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
  end
end
