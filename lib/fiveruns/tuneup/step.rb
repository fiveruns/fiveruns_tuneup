module Fiveruns
  module Tuneup
    
    class RootStep
      
      delegate :<<, :to => :children
      
      def self.layers
        [:model, :view, :controller]
      end
      
      def time
        children.map(&:time).sum
      end
      
      def size
        children.map(&:size).sum
      end
      
      def children
        @children ||= []
      end
      def percentages_by_layer
        @percentages_by_layer ||= self.class.layers.inject({}) do |map, layer|
          map[layer] = if children.empty?
            0
          else
            (children.map { |c| c.layer == layer ? c.time : 0}.sum / children.map(&:time).sum.to_f)
          end
          map
        end
      end
      
    end
    
    class Step < RootStep
      
      attr_reader :name, :layer, :time, :file, :line
      def initialize(name, layer, time, file=nil, line=nil)
        @name = name
        @layer = layer
        @time = time
        @file = file
        @line = line
      end
            
      def size
        children.map(&:size).sum + 1
      end

    end
    
  end
end
  