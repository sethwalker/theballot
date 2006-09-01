class GuidesController < ApplicationController
  before_filter :login_required, :except => [ :show, :list, :index, :xml, :archive, :search ]
  before_filter :check_date, :only => [ :edit, :update ]
  before_filter :legal

  in_place_edit_for :guide, :name
  in_place_edit_for :guide, :description
  in_place_edit_for :guide, :permalink
  in_place_edit_for :guide, :city

  in_place_edit_for :contest, :name
  in_place_edit_for :contest, :description
  in_place_edit_for :choice, :name
  in_place_edit_for :choice, :description
  in_place_edit_for :choice, :selection

  def legal
    @guide ||= Guide.find_by_id(params[:id])
    if @guide && c3? && !@guide.c3?
      return not_found
    end
  end 

  def check_date
    return if current_user.is_admin?
    @guide ||= Guide.find(params[:id])
    if @guide.status && @guide.date.to_date < Time.now.to_date
      flash[:error] = 'Guides cannot be edited after the election has passed' 
      redirect_to :action => 'show', :id => @guide
    end
  end

  def authorized?
    return true if current_user.is_admin?
    if ['edit', 'update', 'destroy'].include?(action_name)
      @guide ||= Guide.find(params[:id])
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
    render :action => 'index', :layout => 'frontpage'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    conditions = "status = '#{Guide::PUBLISHED}'"
    conditions << " AND legal = '#{Guide::C3}'" if c3?
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
    conditions << " AND legal = '#{Guide::C3}'" if c3?
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
      @conditions = "1 = 1"
      @conditions << " AND legal = '#{Guide::C3}'" if c3?
      @conditions << " AND state = '#{params[:guide][:state]}'" if !params[:guide][:state].empty?
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

  def new
    @guide = current_user.guide_in_progress || Guide.new(:name => 'Unsaved Guide', :user => current_user)
    @guide.legal ||= Guide::C3 if c3?
    @guide.save_with_validation(false) unless @guide.id
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
  end

  def create
    if params[:id]
      @guide = Guide.find(params[:id])
      render :action => 'edit' and return unless @guide.update_attributes(params[:guide])
    else
      @guide = Guide.new(params[:guide])
    end
    if params[:image]
      @image = Image.create(params[:image])
      if !@image.valid? && params[:image][:id]
        @image = Image.find(params[:image][:id])
      end
      if @image.valid?
        @guide.image = @image
        current_user.images << @image
      end
    end

    if params[:pdf]
      @pdf = AttachedPdf.create(params[:pdf])
      if @pdf && !@pdf.valid? && params[:pdf][:id]
        @pdf = AttachedPdf.find(params[:pdf][:id])
      end
      if @pdf && @pdf.valid?
        @guide.attached_pdf = @pdf
        current_user.attached_pdfs << @pdf
      end
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
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
  end

  def update
    @guide = Guide.find(params[:id])
    @contest = Contest.new(:guide_id => @guide.id)
    @choice = Choice.new(:contest => @contest)
    return render(:action => 'edit') unless @guide.update_attributes(params[:guide])
    if params[:image]
      @image = Image.create(params[:image])
      if @image && !@image.valid? && params[:image][:id]
        @image = Image.find(params[:image][:id])
      end
      if @image && @image.valid?
        @guide.image = @image
        current_user.images << @image
      end
    end

    if params[:pdf]
      @pdf = AttachedPdf.create(params[:pdf])
      if @pdf && !@pdf.valid? && params[:pdf][:id]
        @pdf = AttachedPdf.find(params[:pdf][:id])
      end
      if @pdf && @pdf.valid?
        @guide.attached_pdf = @pdf
        current_user.attached_pdfs << @pdf
      end
    end

    # this is about the only diff between create
    if 'Unpublish' == params[:commit] || 'Save As Draft' == params[:status]
      @guide.unpublish
    elsif 'Publish' == params[:commit] || 'Publish' == params[:status]
      @guide.publish
    end
    @guide.save!
    flash[:notice] = 'Guide was successfully updated.'
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

  # from: endorsement control window
  # renders: an issue display + edit link in the main guide endorsement list
  def add_issue
    @endorsement = Endorsement.create!(params[:endorsement])
    render :update do |page|
      page.insert_html :bottom, 'endorsements', :partial => 'endorsement', :locals => { :endorsement => @endorsement }
      page['endorsement_contest'].value = ''
      page['endorsement_description'].value = ''
      page['endorsement_selection'].value = Endorsement::NO_ENDORSEMENT
      page['endorsement_contest'].focus
    end
  end

  def add_candidate
    @contest = Contest.find_or_create_by_id(params[:id])
    @choice = Choice.new(:contest => @contest)
  end

  def new_contest
    @endorsement = Endorsement.new(params[:endorsement])
    render :update do |page|
      page.replace_html 'endorsement_form', :partial => 'contest_window', :locals => { :endorsement => @endorsement }
    end
  end

  # in use
  def contest_editor
    @guide = Guide.find(params[:id])
    @contest = Contest.new(:guide_id => params[:id])
    @choice = Choice.new(:contest => @contest)
  end

  def add_candidate_contest
    @contest = Contest.create(params[:contest])
    @choice = Choice.new(:contest => @contest)
    render :update do |page|
      page.replace_html 'contest-edit-window-left', :partial => 'candidate_list', :locals => { :contest => @contest }
      page.replace_html 'contest-edit-window-right', :partial => 'candidate_form', :locals => { :choice => @choice }
    end
  end

  def new_candidate
    @choice = Choice.create(params[:choice])
    render :update do |page|
      page.insert_html :bottom, 'candidate-list', :partial => 'candidate', :locals => { :choice => @choice }
      page['choice_name'].value=''
      page['choice_description'].value=''
      page['choice_selection'].value = Choice::NO_ENDORSEMENT
      page['choice_name'].focus
    end
  end

  def insert_contest
    @contest = Contest.find(params[:id])
    render :update do |page|
      page.insert_html :bottom, 'endorsements', :partial => 'contest', :locals => { :contest => @contest }
      page.sortable 'endorsements', :complete => visual_effect(:highlight, 'endorsements'), :url => { :action => 'order' }
    end
  end

  def new_issue
    return unless params[:id]
    @contest = Contest.create(:guide_id => params[:id], :name => 'Name of referendum (click here to edit)', :description => 'Optional Description of the Referendum')
    @choice = Choice.create(:contest => @contest, :description => 'Your reasoning')
    render :update do |page|
      page.insert_html :bottom, 'endorsements', :partial => 'issue_in_place_editor', :locals => { :contest => @contest, :choice => @choice }
      page << "contest_name_#{@contest.id}_in_place_editor.enterEditMode('click');"
    end
  end

  def old_add_candidate
    @endorsement = Endorsement.create(params[:endorsement])
    render :update do |page|
      if @endorsement
        page.insert_html :bottom, 'candidate-list', :partial => 'candidate', :locals => { :endorsement => @endorsement }
        page['endorsement_candidate'].value=''
        page['endorsement_description'].value=''
        page['endorsement_candidate'].focus
      else
        page.alert('failed')
      end
    end
  end

  def edit_candidate
    @endorsement = Endorsement.find(params[:id])
    render :update do |page|
      page.replace_html 'contest-form', :partial => 'contest_form'
    end
  end

  def update_candidate
    @endorsement = Endorsement.find(params[:id])
    @endorsement.save
    render :update do |page|
      page.replace_html "candidate_#{@endorsement}", :partial => 'candidate', :locals => { :endorsement => @endorsement }
    end
  end

  def add_contest
    @guide = Guide.find(params[:id])
    render :update do |page|
      page.insert_html :bottom, 'endorsements', :partial => 'contest', :locals => { :endorsements => @guide.endorsements.group_by(:contest) }
    end
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
end
