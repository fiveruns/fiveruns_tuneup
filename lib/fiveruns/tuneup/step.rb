module Fiveruns
  module Tuneup
    
    class RootStep
      
      delegate :<<, :blank?, :to => :children
      
      def self.layers
        [:model, :view, :controller]
      end
      
      def time
        children.map(&:time).sum || 0
      end
      
      def size
        children.map(&:size).sum || 0
      end
      
      def children
        @children ||= []
      end
      def percentages_by_layer
        @percentages_by_layer ||= self.class.layers.inject({}) do |map, layer|
          map[layer] = if children.empty?
            0
          else
            these = children.map { |c| c.layer == layer ? c.time : 0}.sum || 0
            all = children.map(&:time).sum || 0
            all == 0 ? 0 : (these / all.to_f)
          end
          map
        end
      end
      
    end
    
    class Step < RootStep
      
      attr_reader :name, :layer, :file, :line
      attr_writer :time
      def initialize(name, layer=nil, file=nil, line=nil)
        @name = name
        @layer = layer
        @file = file
        @line = line
      end
      
      def time
        @time || 0
      end
            
      def size
        children.map(&:size).sum + 1
      end

    end
    
  end
end
  