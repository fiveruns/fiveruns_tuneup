module Fiveruns::Tuneup

  module Routing
    
    def self.install
      ActionController::Routing::RouteSet.send(:include, self)
    end
    
    def self.included(base)
      base.alias_method_chain :draw, :fiveruns_tuneup
    end
    def draw_with_fiveruns_tuneup(*args, &block)
      draw_without_fiveruns_tuneup(*args) do |map|
        map.connect '/tuneup', :controller => 'tuneup', :action => 'show'
        map.connect '/tuneup/:action', :controller => 'tuneup'
        yield map
      end
    end
    
  end
  
end
      
      
  