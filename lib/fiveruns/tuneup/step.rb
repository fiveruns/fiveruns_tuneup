module Fiveruns
  module Tuneup
    
    class RootStep
      
      delegate :blank?, :to => :children
      alias_method :id, :object_id # Avoid record identitication warnings
            
      def self.layers
        framework_layers + [:other]
      end
      
      def self.framework_layers
        [:model, :view, :controller]
      end
      
      def schemas
        @schemas ||= {}
      end
      
      def time
        children.map(&:time).sum || 0
      end
      
      def depth
        @depth ||= 0
      end
      
      def <<(child)
        child.depth = depth + 1
        children << child
      end
      
      def size
        children.map(&:size).sum || 0
      end
      
      def children_with_disparity
        children + [Step.disparity(disparity, self)]
      end
      
      def children
        @children ||= []
      end
      
      def leaf?
        children.blank?
      end
            
      def leaves
        @leaves ||= begin
          if children.blank?
            [self]
          else
            children.map(&:leaves).flatten
          end
        end
      end
      
      def child_times_by_layer
        @child_times_by_layer ||= children.inject(Hash.new(0)) do |totals, child|
          child.percentages_by_layer.each do |layer, percentage|
            totals[layer] += child.time * percentage
          end
          totals
        end
      end
      
      def percentages_by_layer
        @percentages_by_layer ||= begin
          percentages = self.class.framework_layers.inject({}) do |map, layer|
            map[layer] = if leaf?
              self.layer == layer ? 1.0 : 0
            else
              result = child_times_by_layer[layer] / self.time
              result = nil unless result.to_s =~ /\d/
              result.is_a?(Numeric) ? result : 0 # TODO: Fix issue at source
            end
            map
          end
          fill percentages
        end
      end
      
      #######
      private
      #######

      def fill(percentages)
        returning percentages do
          unless leaf?
            if disparity > 0
              percentages[layer] += disparity / self.time
            end
          end
          percentages[:other] ||= 0
          total = percentages.values.sum
          if total < 0.999
            percentages[:other] += 1.0 - total
          end
        end
      end
      
      def disparity
        @disparity ||= begin
          child_total = children.map(&:time).sum || 0
          disparity = time - child_total
          disparity > 0 ? disparity : 0
        end
      end
      
    end
    
    class Step < RootStep
      
      attr_reader :name, :layer, :file, :line, :sql
      attr_accessor :table_name
      attr_writer :time, :depth
      
      def self.disparity(time, parent)
        returning Step.new("Other", parent.layer) do |step|
          step.time = time
        end
      end
      
      def initialize(name, layer=nil, file=nil, line=nil, sql=nil)
        @name = name
        @layer = layer
        @file = file
        @line = line
        @sql = sql
      end
      
      def time
        # FIXME: rank hack to get around weird JRuby YAML bug
        @time.respond_to?(:value) ? @time.value.to_f : @time || 0
      end
            
      def size
        children.map(&:size).sum + 1
      end
      
      class SQL
        
        attr_reader :query, :explain
        
        def initialize(sql, connection)
          @query = sql
          @explain = explain_from(connection)
        end
        
        #######
        private
        #######
        
        def explain_from(connection)
          return nil unless @query =~ /^select\b/i
          return nil unless connection.adapter_name == 'MySQL'
          explain = Explain.new(@query, connection)
          explain if explain.valid?
        end
        
        class Explain
          
          attr_reader :fields, :rows
          
          def initialize(sql, connection)
            result = connection.execute("explain #{sql}")
            @fields = fetch_fields_from(result)
            @rows = fetch_rows_from(result)
            result.free
            add_schemas(connection)
            @valid = true
          rescue Exception
            @valid = false
          end
          
          def valid?
            @valid
          end
          
          def table_offset
            @table_offset ||= @fields.index('table')
          end

          #######
          private
          #######

          def fetch_fields_from(result)
            result.fetch_fields.map(&:name)
          end

          def fetch_rows_from(result)
            returning [] do |rows|
              result.each do |row|
                rows << row
              end
            end
          end
          
          def add_schemas(connection)
            tables.each do |table|
              Fiveruns::Tuneup.add_schema_for(table, connection)
            end
          end
          
          def tables
            return [] unless table_offset
            @rows.map { |row| row[table_offset] }.compact
          end
          
        end

      end

    end
    
  end
end
  