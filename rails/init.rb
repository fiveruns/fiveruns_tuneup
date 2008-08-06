ActionController::Routing::RouteSet.send(:include, Fiveruns::Tuneup::Ext::RouteSet)

Fiveruns::Tuneup.start do
  config.to_prepare { TuneupController.setup }
  [ActionController::Base, ActiveRecord::Base, ActionView::Base].each do |target|
    target.extend Fiveruns::Tuneup::CustomMethods
  end
  ActionController::Base.append_view_path(File.dirname(__FILE__) << "/../views")
  require File.dirname(__FILE__) << "/../install"
end
