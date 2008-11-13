class GuideSweeper < ActionController::Caching::Sweeper
  observe Guide, Comment
  def after_save(record)
    expire_page(:controller => 'guides', :action => 'index')
  end
end
