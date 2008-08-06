module Fiveruns::Tuneup::Ext
  
  module RouteSet
    
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.alias_method_chain :draw, :optional_clear
    end

    module InstanceMethods

      def draw_with_optional_clear(clear = true)
        clear! if clear
        yield ActionController::Routing::RouteSet::Mapper.new(self)
        install_helpers
      end
    end
    
  end
  
end