module Fiveruns::Tuneup::Rails

  module Routing
    
    def self.install
      ActionController::Routing::RouteSet.send(:include, self)
    end
    
    def self.included(base)
      base.alias_method_chain :draw, :fiveruns_tuneup
    end
    def draw_with_fiveruns_tuneup(*args, &block)
      draw_without_fiveruns_tuneup(*args) do |map|
        map.connect '/fiveruns_tuneup_rails/share/*slug', :controller => 'fiveruns_tuneup_rails', :action => 'share'
        yield map
      end
    end
    
  end
  
end
      
      
