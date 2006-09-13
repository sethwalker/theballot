class GuidesController < ApplicationController
  prepend_before_filter :find_guide_by_permalink
  before_filter :login_required, :except => [ :show, :list, :index, :xml, :archive, :by_state, :search, :help ]
  before_filter :check_date, :only => [ :edit, :update_basics ]
  meantime_filter :scope_published, :except => [:edit, :update, :destroy, :update_basics, :update_theme, :update_assets ]
  meantime_filter :scope_approved_guides, :except => [ :show, :edit, :update, :destroy, :update_basics, :update_theme, :update_assets ]

  def scope_approved_guides
    conditions = "approved_at IS NOT NULL OR legal IS NULL OR NOT legal = '#{Guide::C3}'"
    Guide.with_scope({
      :find => { :conditions => conditions }
    }) { yield }
  end

  def scope_published
    Guide.with_scope({
      :find => { :conditions => "status = '#{Guide::PUBLISHED}'" }
    }) { yield }
  end

  in_place_edit_for :guide, :name
  in_place_edit_for :guide, :description
  in_place_edit_for :guide, :permalink
  in_place_edit_for :guide, :city

  in_place_edit_for :contest, :name
  in_place_edit_for :contest, :description
  in_place_edit_for :choice, :name
  in_place_edit_for :choice, :description
  in_place_edit_for :choice, :selection

  def find_guide_by_permalink
    if(params[:year] && params[:permalink])
      Guide.with_scope(:find => { :conditions => ['YEAR(date) = ?', params[:year]] } ) do
        @guide = Guide.find_by_permalink(params[:permalink])
      end
    end
    true
  end

  def check_date
    return true if current_user.is_admin?
    @guide ||= Guide.find(params[:id])
    if @guide.status && @guide.date.to_date < Time.now.to_date
      flash[:error] = 'Guides cannot be edited after the election has passed' 
      redirect_to :action => 'show', :id => @guide and return false
    end
    true
  end

  def authorized?
    return true if current_user.is_admin?
    if ['edit', 'update', 'destroy', 'update_basics', 'update_theme', 'update_assets'].include?(action_name)
      @guide ||= Guide.find(params[:id])
      unless @guide.owner?(current_user)
        flash[:error] = 'Permission Denied'
        return false 
      end
    end
    true
  end

  def access_denied
    flash[:notice] = "This page requires you to log in.  If you don't have a login yet for the ballot.org, it takes about 10 seconds to <a href=\""+ url_for(:action => 'signup') + "\">sign up</a>.  So no whining.  You could be done by now!"
    return super unless logged_in?
    redirect_to :action => 'show', :id => params[:id]
  end

  def xml
    @guide = Guide.find(params[:id])
    render :xml => @guide.to_xml(:include => :endorsements)
  end
  
  def index
    list
    render :action => 'index', :layout => 'frontpage'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @conditions ||= {} 
    @messages ||= []
    @conditions[:date] ||= "date >= '#{Time.now.to_s(:db)}'"
    @guide_pages, @guides = paginate :guides, :per_page => 10, :conditions => @conditions.values.join(' AND '), :order => 'state, city, date'
  end

  def by_state
    @state = params[:state]
    redirect_to :action => 'list' and return if @state == 'all'
    @conditions ||= {}
    @messages ||= []
    @conditions[:state] = "state = '#{@state}'"
    @listheader = "Showing All Guides from #{@state}"
    list
    if @guides.empty?
      @messages << "There are no guides for the region you selected.  <a href=\""+url_for(:action => 'new')+"\">Create one!</a> -- we'll show you how.  <a href=\""+url_for(:action => 'index')+"\">back to map</a>"
    else
      @messages << "Don't see a guide for your area?  Or don't agree with the ones there are?  <a href=\""+url_for(:action => 'new')+"\">Create your own!</a> -- we'll show you how."
    end
    render :action => 'list'
  end

  def archive
    @conditions ||= {}
    @conditions[:date] = "date < '#{Time.now.to_s(:db)}'"
    list
    render :action => 'list'
  end

  def search
    if params[:q]
      @query = params[:q]
      @guide_pages = Paginator.new self, Guide.count, 10, params['page']
      @guides = Guide.find_by_contents(@query, :limit => @guide_pages.items_per_page, :offset => @guide_pages.current.offset)
      @listheader = "Searching for \"#{@query}\""
      @messages = ["No results"] if @guides.empty?
      render :action => 'list' and return
    elsif params[:guide]
      @query = Array.new
      @query << "name:#{params[:guide][:name]}" if !params[:guide][:name].empty?
      @query << "description:#{params[:guide][:description]}" if !params[:guide][:description].empty?
      @query << "city:#{params[:guide][:city]}" if !params[:guide][:city].empty?
      @query = ['*'] if @query.empty?
      @conditions = "1 = 1"
      @conditions << " AND state = '#{params[:guide][:state]}'" if !params[:guide][:state].empty?
      @guide_pages = Paginator.new self, Guide.count, 10, params['page']
      Guide.with_scope(:find => { :conditions => @conditions }) do
        @guides = Guide.find_by_contents(@query.join(' AND '), :limit => @guide_pages.items_per_page, :offset => @guide_pages.current.offset)
      end
      @listheader = "Searching for \"#{@query}\""
      @messages = ["No results"] if @guides.empty?
      render :action => 'list' and return
    end
  end

  def show
    @guide ||= Guide.find(params[:id]) if params[:id]
    return not_found unless @guide
    if !@guide.is_published?
      if logged_in? && @guide.owner?(current_user)
        flash[:notice] = 'you are viewing this guide in preview mode'
      else
        return not_found
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

  def create
    if params[:id]
      @guide = Guide.find(params[:id])
      render :action => 'edit' and return unless @guide.update_attributes(params[:guide])
    else
      @guide = Guide.new(params[:guide])
    end
    @image = @guide.create_image(:uploaded_data => params[:uploaded_image]) if params[:uploaded_image] && params[:uploaded_image].size != 0
    current_user.images << @image if @image && @image.valid?
    @pdf = @guide.create_attached_pdf(:uploaded_data => params[:uploaded_pdf]) if params[:uploaded_pdf] && params[:uploaded_pdf].size != 0
    current_user.attached_pdfs << @pdf if @pdf && @pdf.valid?

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

  def new
    @guide = current_user.guide_in_progress(c3?) || Guide.new(:user => current_user, :date => Date.new(2006,11,7), :state => current_user.state)
    @guide.legal = Guide::C3 if c3?
    @guide.save_with_validation(false) unless @guide.id
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
    render :action => 'edit'
  end

  def edit
    @guide = Guide.find(params[:id])
    @image = @guide.image
    @pdf = @guide.attached_pdf
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
  end

  def update_basics
    @guide ||= Guide.find(params[:id])
    @current = 'basics'
    @next = 'theme' unless @guide.theme
    @saved = @guide.update_attributes(params[:guide])
    update_section
  end

  def update_theme
    @guide ||= Guide.find(params[:id])
    @current = 'theme'
    @guide.update_attribute_with_validation_skipping(:theme_id, params[:guide][:theme_id])
    @saved = true
    update_section
  end

  def update_section
    if @saved
      render :update do |page|
        page << "invi('guide-form-#{@current}', true)"
        page << "invi('guide-form-#{@next}', false)" if @next
        page << "Element.setStyle('guide_description', {overflow:'hidden'})"
        page.replace_html 'guide-preview-contents', :file => 'guides/preview', :layout => false
      end
    else
      render :update do |page|
        page.replace_html "guide-#{@current}-error-messages", format_error_messages('guide')
      end
    end
  end

  def update_assets
    @guide ||= Guide.find(params[:id])
    @image = @guide.create_image(:uploaded_data => params[:uploaded_image]) if params[:uploaded_image] && params[:uploaded_image].size != 0
    current_user.images << @image if @image && @image.valid?
    @pdf = @guide.create_attached_pdf(:uploaded_data => params[:uploaded_pdf]) if params[:uploaded_pdf] && params[:uploaded_pdf].size != 0
    current_user.attached_pdfs << @pdf if @pdf && @pdf.valid?
    if (@image and !@image.valid?) or (@pdf and !@pdf.valid?)
      render :action => 'edit'
    else
      redirect_to :action => 'edit', :id => @guide
    end
  end

  def update
    @guide = Guide.find(params[:id])
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
    return render(:action => 'edit') unless @guide.update_attributes(params[:guide])

    # this is about the only diff between create
    if 'Unpublish' == params[:commit] || 'Save As Draft' == params[:commit]
      @guide.unpublish
    elsif 'Publish Guide' == params[:commit] || 'Submit Guide' == params[:commit]
      @guide.publish
    end
    @guide.save!
    flash[:notice] = 'Guide was successfully updated.  To edit [or publish] your guide, click on "My Stuff" in the upper right'
    redirect_to :action => 'show', :id => @guide

  rescue ActiveRecord::MultiparameterAssignmentErrors
    @guide.errors.add :date
    render :action => 'edit'
  end

  def destroy
    Guide.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def order
    @order = params[:contests]
    if params[:id]
      @guide = Guide.find(params[:id])
      @guide.contests.each do |e|
        e.position = @order.index(e.id.to_s) + 1
        e.save
      end
    end
    render :nothing => true
  end

  def preview
    render :layout => false
  end

  # in use
  def contest_editor
    @guide = Guide.find(params[:id])
    @contest = Contest.new(:guide_id => params[:id])
    @choice = Choice.new(:contest => @contest)
  end

  def endorsed_status
    @guide = Guide.find(params[:id])
    @guide.update_attributes(:endorsed => params[:endorsed])
    render :partial => 'endorse', :locals => { :guide => @guide }, :layout => false
  end

  def approved_status
    @guide = Guide.find(params[:id])
    @guide.approve(current_user) if params[:approved]
    render :partial => 'approve', :locals => { :guide => @guide }, :layout => false
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

  def help
    render :layout => false
  end
end
