require 'dispatcher'
Dispatcher.to_prepare :tuneup_route do
  ActionController::Routing::Routes.add_route '/tuneup', :controller => 'tuneup', :action => 'show'
  ActionController::Routing::Routes.add_route '/tuneup/:action', :controller => 'tuneup'  
end
ActionController::Base.view_paths.push(File.dirname(__FILE__) << "/../views")
Fiveruns::Tuneup.start