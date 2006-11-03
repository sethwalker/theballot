ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "guides"

  map.guide_permalink ':year/:permalink', :controller => 'guides', :action => 'show', :requirements => { :year => /\d+/ }
  map.connect ':year', :controller => 'guides', :action => 'by_date', :requirements => { :year => /\d+/ }

  map.connect 'state/:state', :controller => 'guides', :action => 'by_state'
  map.connect 'guides/by_state/:state', :controller => 'guides', :action => 'by_state'

  map.connect 'contests/candidate/:action/:id', :controller => 'contests/candidate'
  map.connect 'contests/referendum/:action/:id', :controller => 'contests/referendum'
  map.connect 'contests/:action/:id', :controller => 'contests/base'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

  map.connect '*from', :controller => 'application', :action => 'render_404'
end
