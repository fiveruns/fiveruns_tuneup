module Fiveruns::Tuneup
  
  module Routes
    
    def add_routes
      ::ActionController::Routing::Routes.draw(false) do |map|
        map.connect '/tuneup', :controller => 'tuneup', :action => 'show'
        map.connect '/tuneup/:action', :controller => 'tuneup'
      end
    end
    
  end
  
end