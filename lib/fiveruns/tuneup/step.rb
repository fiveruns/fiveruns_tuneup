module Fiveruns
  module Tuneup
    
    class RootStep
      
      delegate :blank?, :to => :children
      alias_method :id, :object_id # Avoid record identitication warnings
            
      def self.layers
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
      
      def children
        @children ||= []
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
      
      def percentages_by_layer
        @percentages_by_layer ||= self.class.layers.inject({}) do |map, layer|
          map[layer] = if leaves.empty?
            if respond_to?(:layer, true) && self.layer == layer
              1.0
            else
              0
            end
          else
            these = leaves.map { |c| c.layer == layer ? c.time : 0}.sum || 0
            all = leaves.map(&:time).sum || 0
            all == 0 ? 0 : (these / all.to_f)
          end
          map
        end
      end
      
    end
    
    class Step < RootStep
      
      attr_reader :name, :layer, :file, :line, :sql
      attr_writer :time, :depth, :table_name
      def initialize(name, layer=nil, file=nil, line=nil, sql=nil)
        @name = name
        @layer = layers
        @file = file
        @line = line
        @sql = sql
      end
      
      def time
        @time || 0
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
        #  rescue Exception
        #    @valid = false
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
  