class GuidesController < ApplicationController
  prepend_before_filter :find_guide_by_permalink
  before_filter :login_required, :except => [ :show, :list, :list_past, :index, :xml, :archive, :by_date, :by_state, :search, :help, :instructions, :tell, :send_message, :credits ]

  #don't allow guides to be edited after the date of the election
  before_filter :check_date, :only => [ :edit, :update_basics ]
  around_filter :scope_published, :except => [ :new, :show, :edit, :update, :destroy, :update_basics, :update_theme, :update_assets, :update_legal, :endorsed_status, :approved_status, :published_status, :order, :admin ]
  around_filter :scope_approved_guides, :except => [ :new, :show, :edit, :update, :destroy, :update_basics, :update_theme, :update_assets, :update_legal, :endorsed_status, :approved_status, :published_status, :order ]

  def credits
  end

  def scope_approved_guides
    Guide.with_approved { yield }
  end

  def scope_published
    Guide.with_published { yield }
  end

  def admin
    @guides = Guide.find(:all)
    @published = @guides.find_all {|g| g.published?}
    @unpublished = @guides.find_all {|g| !g.published?}

  end

  def find_guide_by_permalink
    if(params[:year] && params[:permalink])
      @guide = Guide.find_by_permalink(params[:permalink], :conditions => ['YEAR(date) = ?', params[:year]])
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
    return true if ['new', 'join', 'unjoin'].include?(action_name)
    if ['edit', 'update', 'destroy', 'update_basics', 'update_theme', 'update_assets', 'update_legal', 'order'].include?(action_name)
      @guide ||= Guide.find(params[:id])
      return true if @guide.owner?(current_user)
    end
    flash[:error] = 'Permission Denied'
    false 
  end

  def access_denied
    flash[:notice] = "This page requires you to log in.  If you don't have a login, it takes about 10 seconds to sign up below."
    return super unless logged_in?
    redirect_to :action => 'show', :id => params[:id]
  end

  def xml
    @guide = Guide.find(params[:id])
    render :xml => @guide.to_xml(:include => :contests)
  end
  
  def index
    @showing_author = true
    list
    @conditions = {} #hack
    list_past
    render :action => 'index', :layout => 'frontpage'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @conditions ||= {} 
    @messages ||= []
    @listheader ||= "Listing All Voter Guides"
    @conditions[:date] ||= "date >= '#{(1.week.ago).to_s(:db)}'"
    @guides = Guide.paginate :all, :page => params[:page], :per_page => 25, :conditions => @conditions.values.join(' AND '), :order => 'date, endorsed DESC, num_members DESC, state DESC, city'
  end

  def list_past
    @conditions ||= {} 
    @messages ||= []
    @listheader ||= "Listing Past Voter Guides"
    @conditions[:date] ||= "date < '#{(Time.now).to_s(:db)}'"
    @guides_past = Guide.paginate :page => params[:page], :per_page => 25, :conditions => @conditions.values.join(' AND '), :order => 'date DESC, endorsed DESC, num_members DESC, state, city'
  end

  def by_date
    @conditions = { :date => "YEAR(date) = #{params[:year]}" }
    @listheader = "Listing All Voter Guides for #{params[:year]}"
    list
    render :action => 'list'
  end

  def by_state
    @state = params[:state]
    redirect_to :action => 'list' and return if @state == 'all'
    @conditions ||= {}
    @messages ||= []
    @conditions[:state] = "state = '#{@state}'"
    @listheader = "Showing All Guides from #{@state}"
    list
    if @guides.empty? && request.env['HTTP_REFERER'] && !request.env['HTTP_REFERER'].include?(request.host)
        flash[:notice] = "There are no guides for the region you selected."
        redirect_to :action => 'index' and return
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
      @query = params[:q].split.collect {|p| ['and', 'or', '*'].include?(p.downcase) || p.include?('*') ? p : p + '*'}.join(' ')
      @guides = Guide.find_with_ferret(@query, :page => params[:page], :per_page => 10)
      @pagination_params = { :q => params[:q] }
      @listheader = "Searching for \"#{@query.gsub(/\*/,'')}\""
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
      @guides = Guide.find_with_ferret(@query.join(' AND '), :conditions => @conditions, :page => params[:page], :per_page => 10)
      @listheader = "Searching for \"#{@query}\""
      @messages = ["No results"] if @guides.empty?
      render :action => 'list' and return
    end
  end

  def show
    @guide = Guide.find(@guide.id) if @guide
    @guide ||= Guide.find(params[:id]) if params[:id]
    return not_found unless @guide
    flash[:notices] ||= []
    if !@guide.is_published?
      if logged_in? && (@guide.owner?(current_user) || current_user.admin?)
        flash[:notices] << 'you are viewing this guide in preview mode'
      else
        return not_found
      end
    end
    if !@guide.approved?
      if logged_in? && (@guide.owner?(current_user) || current_user.admin?)
        flash[:notices] << 'this guide has not been published so it is not visible to the public'
      else
        return not_found
      end
    end
    if !@guide.theme.nil?
      Liquid::Template.register_filter(ActionView::Helpers::TagHelper)
      Liquid::Template.register_filter(ActionView::Helpers::TextHelper)
      template = Liquid::Template.parse(Theme.find(@guide.theme.id).markup)
      @liquid = template.render('guide' => @guide, 'host' => request.host)
    end
    @body_id = 'guides-show'
    flash.now[:notice] = flash[:notices].join('<br/>') if !flash[:notices].empty?
    render :action => 'show'
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
    if c3?
      @guide = current_user.guides.in_progress.nonpartisan.find(:first)
    else
      @guide = current_user.guides.in_progress.partisan.find(:first)
    end
    @guide ||= Guide.new(:user => current_user, :date => Date.new(2008,11,4), :state => current_user.state, :theme_id => 1)
    if @guide.new_record?
      @guide.legal = Guide::NONPARTISAN if c3?
      @guide.save_with_validation(false)
      @recently_created_guide = true
    end
    render :template => 'guides/c3/instructions' and return if c3?
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
    render :update do |page|
      if @guide.update_attributes(params[:guide])
        page << "invi('guide-form-basics', true)"
        page << "invi('guide-form-theme', false)" if params[:show_theme]
        page.replace_html 'guide-preview-contents', :file => 'guides/preview', :use_full_path => true
        page << "Element.setStyle('guide_description', {overflow:'hidden'})"
        page.replace_html 'guide-form-basics', :partial => 'guides/basics_form', :layout => false
      else
        page.replace_html "guide-basics-error-messages", format_error_messages('guide')
      end
    end
  end

  def update_theme
    @guide ||= Guide.find(params[:id])
    @guide.update_attribute_with_validation_skipping(:theme_id, params[:guide][:theme_id])
    render :update do |page|
      page << "invi('guide-form-theme', true)"
      page.replace_html 'guide-preview-contents', :file => 'guides/preview', :use_full_path => true
    end
  end

  def update_assets
    @guide ||= Guide.find(params[:id])
    @image = @guide.create_image(:uploaded_data => params[:uploaded_image]) if params[:uploaded_image] && params[:uploaded_image].size != 0
    current_user.images << @image if @image && @image.valid?
    @pdf = @guide.create_attached_pdf(:uploaded_data => params[:uploaded_pdf]) if params[:uploaded_pdf] && params[:uploaded_pdf].size != 0
    current_user.attached_pdfs << @pdf if @pdf && @pdf.valid?
    if (@image and !@image.valid?) or (@pdf and !@pdf.valid?)
      @guide.attached_pdf(true) if @pdf
      @guide.image(true) if @image
      render :action => 'edit'
    else
      redirect_to :action => 'edit', :id => @guide
    end
  end

  def update
    @guide = Guide.find(params[:id])
    return render(:action => 'edit') unless @guide.update_attributes(params[:guide])

    if 'Unpublish' == params[:commit] || 'Save As Draft' == params[:commit]
      @guide.unpublish
    elsif 'Publish Guide' == params[:commit] || 'Submit Guide' == params[:commit]
      @guide.publish
    end
    @guide.legal = Guide::NONPARTISAN if c3?
    @guide.save!
    flash[:notices] ||= []
    flash[:notices] << "Guide was successfully updated.  #{'To publish your guide, edit it and click Submit Guide.  ' unless @guide.is_published?}"
    flash[:notices] << "As soon as we check your guide to make sure it's non-partisan, it will be publicly visible on the site.  That usually happens the same day.  If you have questions email us at voterguides@youngvoter.org." if @guide.c3? && @guide.instance_variable_get(:@recently_published)
    redirect_to = { :year => @guide.date.year, :permalink => @guide.permalink }
    redirect_to[:host] = session[:login_domain] if session[:login_domain] && session[:login_domain] != request.host
    redirect_to guide_permalink_url(redirect_to)
  rescue ActiveRecord::MultiparameterAssignmentErrors
    @guide.errors.add :date
    render :action => 'edit'
  end

  def destroy
    Guide.find(params[:id]).destroy
    if request.xhr?
      render :update do |page|
        page.remove "guide_#{params[:id]}"
      end
    else
      redirect_to :action => 'list'
    end
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

  def published_status
    @guide ||= Guide.find(params[:id])
    return unless @guide
    if params[:publish]
      @guide.status = Guide::PUBLISHED
    else
      @guide.status = Guide::UNPUBLISHED
    end
    @guide.save
    render :partial => 'guides/publish', :locals => { :guide => @guide }, :layout => false
  end

  def join
    @guide = Guide.find(params[:id])
    @guide.add_member(current_user)
    if request.xhr?
      render :partial => 'pledge', :locals => { :guide => @guide }, :layout => false
    else
      redirect_to guide_permalink_url(:year => @guide.date.year, :permalink => @guide.permalink)
    end
  end

  def unjoin
    @guide = Guide.find(params[:id])
    @guide.remove_member(current_user)
    if request.xhr?
      render :partial => 'account/blocs', :locals => {:user => current_user}, :layout => false
    else
      redirect_to guide_permalink_url(:year => @guide.date.year, :permalink => @guide.permalink)
    end
  end

  def tell
    @guide = Guide.find(params[:id])
  end

  def send_message
    @guide = Guide.find(params[:id])
    @tell = { :recipients => params[:recipients][:email], :guide => @guide, :message => params[:recipients][:message], :from_name => logged_in? ? "#{current_user.firstname} #{current_user.lastname}" : params[:from][:name], :from_email => logged_in? ? current_user.email : params[:from][:email], :host => request.host }
    unless @tell[:from_email] =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      flash.now[:error] = "Invalid email address"
      render :action => :tell and return
    end
    if GuidePromoter.deliver_tell_a_friend(@tell)
      flash[:notices] = ["An email has been sent to your friend about this guide."]
      redirect_to guide_permalink_url(:year => @guide.date.year, :permalink => @guide.permalink) 
    else
      render :action => :tell
    end
  end

  def help
    render :layout => false
  end

  def instructions
    if params[:id] && params[:id] == 'c3'
      render :action => 'c3/instructions', :layout => 'instructions'
    end
  end

  def update_legal
    @guide ||= Guide.find(params[:id])
    @legal = params[:legal]
    if @legal == Guide::PARTISAN
      @guide.update_attribute_with_validation_skipping(:legal, Guide::PARTISAN)
    elsif @legal == Guide::NONPARTISAN
      @guide.update_attribute_with_validation_skipping(:legal, Guide::NONPARTISAN)
      @recently_updated_guide_legal_status = true
      render :template => 'guides/c3/instructions' and return
    else
      if request.xhr?
        render :update do |page|
          page.alert 'did not recognize that legal status'
        end
      else
        flash[:error] = 'did not recognize that legal status'
        redirect_to :action => 'edit', :id => @guide
      end
      return
    end
    redirect_to :action => 'edit', :id => @guide
  end

end
