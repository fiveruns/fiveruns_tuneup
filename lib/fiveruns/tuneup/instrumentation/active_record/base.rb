module Fiveruns
  module Tuneup
    module Instrumentation
      module ActiveRecord
        module Base
          
          def self.record(event, model, &operation)
            Fiveruns::Tuneup.step("Model #{event.to_s.titleize}: #{model}", :model, &operation)
          end
          
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods, ClassMethods
          end
               
          module ClassMethods
            
            #
            # FINDS
            #
            
            def find_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :find,  self do
                find_without_fiveruns_tuneup(*args, &block)
              end
            end
            def find_by_sql_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :find_by_sql, self do
                find_by_sql_without_fiveruns_tuneup(*args, &block)
              end
            end
            
            #
            # CREATE
            #
            
            def create_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :create, self do
                create_without_fiveruns_tuneup(*args, &block)
              end
            end
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self do
                update_without_fiveruns_tuneup(*args, &block)
              end
            end
            def update_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self do
                update_all_without_fiveruns_tuneup(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                destroy_without_fiveruns_tuneup(*args, &block)
              end
            end
            def destroy_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                destroy_all_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                delete_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_all_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                delete_all_without_fiveruns_tuneup(*args, &block)
              end
            end
          end
          module InstanceMethods
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                update_without_fiveruns_tuneup(*args, &block)
              end
            end
            def save_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                save_without_fiveruns_tuneup(*args, &block)
              end
            end
            def save_with_fiveruns_tuneup!(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                save_without_fiveruns_tuneup!(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self.class do
                destroy_without_fiveruns_tuneup(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end