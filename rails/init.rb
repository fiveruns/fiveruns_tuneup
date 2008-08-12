Fiveruns::Tuneup.start do
  require 'dispatcher'
  
  Fiveruns::Tuneup::Routing.install
      
  Dispatcher.to_prepare :tuneup_controller_filters do
    TuneupController.filter_chain.clear
    TuneupController.before_filter :find_config, :except => :index
  end
  [ActionController::Base, ActiveRecord::Base, ActionView::Base].each do |target|
    target.extend Fiveruns::Tuneup::CustomMethods
  end
  ActionController::Base.append_view_path(File.dirname(__FILE__) << "/../views")
  require File.dirname(__FILE__) << "/../install" # Check for assets
end
