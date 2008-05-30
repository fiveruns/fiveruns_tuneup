require 'dispatcher'
Dispatcher.to_prepare :tuneup_route do
  ActionController::Routing::Routes.add_route '/tuneup', :controller => 'tuneup', :action => 'show'
  ActionController::Routing::Routes.add_route '/tuneup/:action', :controller => 'tuneup'
  2.times do
    route = ActionController::Routing::Routes.routes.pop
    ActionController::Routing::Routes.routes.unshift(route)
  end
end
Dispatcher.to_prepare :tuneup_controller_filters do
  TuneupController.filter_chain.clear
  TuneupController.before_filter :find_config, :except => :index
end
[ActionController::Base, ActiveRecord::Base, ActionView::Base].each do |target|
  target.extend Fiveruns::Tuneup::CustomMethods
end

ActionController::Base.append_view_path(File.dirname(__FILE__) << "/../views")
require File.dirname(__FILE__) << "/../install" # Check for assets
Fiveruns::Tuneup.start