module Fiveruns
  module Tuneup
    module Schema
      
      def schemas
        @schemas ||= {}
      end
              
      def add_schema_for(table, connection)
        schemas[table] ||= begin
          {
            :columns => columns_for(table, connection),
            :indexes => indexes_for(table, connection)
          }
        end
      end
        
      #######
      private
      #######
      
      def columns_for(table, connection)
        connection.columns(table).map do |column|
          extract(column, :name, :sql_type)
        end
      end
      
      def indexes_for(table, connection)
        connection.indexes(table).map do |index|
          extract(index, :name, :unique, :columns)
        end
      end
      
      def extract(obj, *fields)
        fields.inject({}) do |hash, field|
          hash[field] = obj.__send__(field)
          hash
        end
      end
      
    end
  end
end