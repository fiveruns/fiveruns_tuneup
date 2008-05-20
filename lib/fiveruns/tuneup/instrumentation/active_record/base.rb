module Fiveruns
  module Tuneup
    module Instrumentation
      module ActiveRecord
        module Base
          
          def self.record(name, sql=nil, connection=nil, &operation)
            explain_data = explain(sql, connection) if sql && connection
            Fiveruns::Tuneup.step(name, :model, true, sql, explain_data, &operation)
          end
          
          def self.explain(sql, connection)
            return nil unless sql =~ /^select /i
            result = connection.execute("explain #{sql}")
            [result.fetch_fields.map(&:name), result.fetch_row]
          end
          
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods, ClassMethods
          end
               
          module ClassMethods
            
            #
            # FINDS
            #
            
            def find_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Find #{self.name}" do
                find_without_fiveruns_tuneup(*args, &block)
              end
            end
            def find_by_sql_with_fiveruns_tuneup(conditions, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Find #{self.name} by SQL", sanitize_sql(conditions), connection do |sql|
                find_by_sql_without_fiveruns_tuneup(sql, &block)
              end
            end
            
            #
            # CREATE
            #
            
            def create_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Create #{self.name}" do
                create_without_fiveruns_tuneup(*args, &block)
              end
            end
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Update #{self.name}" do
                update_without_fiveruns_tuneup(*args, &block)
              end
            end
            def update_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Update #{self.name}" do
                update_all_without_fiveruns_tuneup(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Delete #{self.name}" do
                destroy_without_fiveruns_tuneup(*args, &block)
              end
            end
            def destroy_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Delete #{self.name}" do
                destroy_all_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Delete #{self.name}" do
                delete_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Delete #{self.name}" do
                delete_all_without_fiveruns_tuneup(*args, &block)
              end
            end
          end
          module InstanceMethods
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Update #{self.class.name}" do
                update_without_fiveruns_tuneup(*args, &block)
              end
            end
            def save_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Update #{self.class.name}" do
                save_without_fiveruns_tuneup(*args, &block)
              end
            end
            def save_with_fiveruns_tuneup!(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Update #{self.class.name}" do
                save_without_fiveruns_tuneup!(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Delete #{self.class.name}" do
                destroy_without_fiveruns_tuneup(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end