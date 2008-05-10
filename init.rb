require 'dispatcher'
Dispatcher.to_prepare :tuneup_route do
  ActionController::Routing::Routes.add_route '/tuneup', :controller => 'tuneup', :action => 'show'
  ActionController::Routing::Routes.add_route '/tuneup/:action', :controller => 'tuneup'
end
ActionView::Base.send(:include, TuneupHelper)
ActionController::Base.view_paths << File.join(directory, 'views')