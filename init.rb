require 'dispatcher'
Dispatcher.to_prepare :tuneup_route do
  ActionController::Routing::Routes.add_route '/tuneup/:action', :controller => 'tuneup'
end
ActionController::Base.view_paths << File.join(directory, 'views')