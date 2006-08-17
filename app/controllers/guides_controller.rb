class GuidesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update ]
  before_filter :check_date, :only => [ :edit, :update ]

  def check_date
    return if current_user.is_admin?
    @guide = Guide.find(params[:id])
    if @guide.date.to_date < Time.now.to_date
      flash[:error] = 'Guides cannot be edited after the election has passed' 
      redirect_to :action => 'show', :id => @guide
    end
  end

  def authorized?
    if ['edit', 'update', 'destroy'].include?(action_name)
      @guide = Guide.find(params[:id])
      unless @guide.owner?(current_user) || current_user.is_admin?
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
    if params[:state]
      conditions << " AND state = '#{params[:state]}'"
      flash[:notice] = "Showing All Guides from #{params[:state]}"
      @state = params[:state]
    end
    conditions << " AND user_id = '#{params[:author]}'" if params[:author]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions, :order => 'state, city, date'
  end

  def archive
    conditions = "status = '#{Guide::PUBLISHED}'"
    conditions << " AND date < '#{Time.now.to_s(:db)}'"
    if params[:state]
      conditions << " AND state = '#{params[:state]}'"
      flash[:notice] = "Showing All Guides from #{params[:state]}"
      @state = params[:state]
    end
    conditions << " AND user_id = '#{params[:author]}'" if params[:author]
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => conditions, :order => 'state, city, date'
    render :action => 'list'
  end

  def search
    if params[:guide]
      @query = Array.new
      @query << "name:#{params[:guide][:name]}" if !params[:guide][:name].empty?
      @query << "description:#{params[:guide][:description]}" if !params[:guide][:description].empty?
      @query << "city:#{params[:guide][:city]}" if !params[:guide][:city].empty?
      @query = ['*'] if @query.empty?
      @conditions = "state = '#{params[:guide][:state]}'" if !params[:guide][:state].empty?
      @conditions ||= "1 = 1"
      @guide_pages = Paginator.new self, Guide.count, 10, params['page']
      Guide.with_scope(:find => { :conditions => @conditions }) do
        @guides = Guide.find_by_contents(@query.join(' AND '), :limit => @guide_pages.items_per_page, :offset => @guide_pages.current.offset)
      end
      render :action => 'list' and return
    end
  end

  def show
    if(params[:year] && params[:month] && params[:day] && params[:permalink])
      Guide.with_scope(:find => { :conditions => ['date = ?', Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i).to_s] } ) do
        @guide = Guide.find_by_permalink(params[:permalink])
      end
    else
      @guide = Guide.find(params[:id])
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
      @rendered = template.render('guide' => @guide)
    end
    render :action => 'show', :layout => 'sidebar'
  end

  def not_found
    flash[:error] = 'Guide not found'
    redirect_to :action => :list
  end

  def new
    @guide = Guide.new
    @status = params[:id]
  end

  def create
    order = params[:order].split(/,\s*/) if params[:order]
    @guide = Guide.new(params[:guide])
    if params.include?('endorsements')
      params[:endorsements].each do |i,e|
        position = !order.nil? ? order.index(i.to_s) + 1 : i.to_i + 1
        @guide.endorsements.build(e.merge(:position => position))
      end
    end
    @image = Image.create(params[:image])
    if !@image.valid? && params[:image][:id]
      @image = Image.find(params[:image][:id])
    end
    if @image.valid?
      @guide.image = @image
      current_user.images << @image
    end

    @pdf = AttachedPdf.create(params[:pdf])
    if !@pdf.valid? && params[:pdf][:id]
      @pdf = AttachedPdf.find(params[:pdf][:id])
    end
    if @pdf.valid?
      @guide.attached_pdf = @pdf
      current_user.attached_pdfs << @pdf
    end

    @guide.user = current_user
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
    @image = @guide.image
    @pdf = @guide.attached_pdf
  end

  def update
    @guide = Guide.find(params[:id])
    return render :action => 'edit' unless @guide.update_attributes(params[:guide])
    if params.include?('endorsements')
      params[:endorsements].each do |i,e|
        endorsement = @guide.endorsements.build(e)
        endorsement.position = order.index(i) + 1 if !order.nil?
      end
    end

    @image = Image.create(params[:image])
    if !@image.valid? && params[:image][:id]
      @image = Image.find(params[:image][:id])
    end
    if @image.valid?
      @guide.image = @image
      current_user.images << @image
    end

    @pdf = AttachedPdf.create(params[:pdf])
    if !@pdf.valid? && params[:pdf][:id]
      @pdf = AttachedPdf.find(params[:pdf][:id])
    end
    if @pdf.valid?
      @guide.attached_pdf = @pdf
      current_user.attached_pdfs << @pdf
    end

    if 'Unpublish' == params[:commit]
      @guide.unpublish
    elsif 'Publish' == params[:commit]
      @guide.publish
    end
    @guide.save
    flash[:notice] = 'Guide was successfully updated.'
    redirect_to :action => 'show', :id => @guide
  end

  def destroy
    Guide.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def order
    @order = params[:endorsements]
    return render(:partial => 'order', :locals => { :order => @order }) unless params[:id]
    if params[:id]
      @guide = Guide.find(params[:id])
      @guide.endorsements.each do |e|
        e.position = @order.index(e.id.to_s) + 1
        e.save
      end
      return render :nothing => true
    end
  end

  def replace_endorsement
    @endorsement = Endorsement.new(params[:endorsement])
    render :update do |page|
      page.replace "endorsement_#{params[:index]}", :partial => 'endorsement', :locals => { :endorsement => @endorsement, :index => params[:index] }
      page.replace "endorsement_#{params[:index]}_hiddens", :partial => 'endorsements/hiddens', :locals => { :endorsement => @endorsement, :index => params[:index] }
      page.sortable 'endorsements', :complete => visual_effect(:highlight, 'endorsements'), :url => { :controller => 'guides', :action => 'order' }, :update => 'endorsement_order'
    end
  end

  def remove_endorsement
    @index = params[:index]
  end

  def add_endorsement
    return unless params[:id]
    @endorsement = Endorsement.new(params[:endorsement])
    @endorsement.guide_id = params[:id]
    return unless @endorsement.save
    render :update do |page|
      page.insert_html :bottom, 'endorsements', :partial => 'endorsement', :locals => { :endorsement, @endorsement }
      page.sortable 'endorsements', :complete => visual_effect(:highlight, 'endorsements'), :url => { :action => 'order' }
      page['endorsement_contest'].value = ''
      page['endorsement_candidate'].value = ''
      page['endorsement_description'].value = ''
      page['endorsement_selection'].value = Endorsement::NO_ENDORSEMENT
      page['endorsement_contest'].focus()
    end
  end

  def endorsed_status
    @guide = Guide.find(params[:id])
    @guide.update_attributes(:endorsed => params[:endorsed])
    render :partial => 'endorse', :locals => { :guide => @guide }, :layout => false
  end

  def join
    @guide = Guide.find(params[:id])
    pledge = Pledge.new
    @guide.pledges << pledge
    current_user.pledges << pledge
    pledge.save
    render :partial => 'pledge', :locals => { :guide => @guide }, :layout => false
  end

  def unjoin
    pledge = Pledge.find_by_guide_id_and_user_id(params[:id], current_user.id)
    pledge.destroy
    render :partial => 'pledge', :locals => { :guide => @guide }, :layout => false
  end

  def tell
    @guide = Guide.find(params[:id])
  end

  def send_message
    @guide = Guide.find(params[:id])
    @tell = { :recipients => params[:recipients][:email], :guide => @guide, :message => params[:recipients][:message], :user => current_user }
    if GuidePromoter.deliver_tell_a_friend(@tell)
      flash[:notice] = "Message sent"
      render :action => :show and return
    end
    render :action => :tell
  end
end
