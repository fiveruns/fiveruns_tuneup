module Fiveruns
  module Tuneup
    module Instrumentation
      module ActiveRecord
        module Base
          
          def self.record(name, &operation)
            Fiveruns::Tuneup.step(name, :model, &operation)
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
            def find_by_sql_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record "Find #{self.name} by SQL" do
                find_by_sql_without_fiveruns_tuneup(*args, &block)
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