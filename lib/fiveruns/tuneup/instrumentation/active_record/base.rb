module Fiveruns
  module Tuneup
    module Instrumentation
      module ActiveRecord
        module Base
          
          # 1. Store the current model name so error metrics during execution can refer to it
          # 2. Execute the operation, time it, and store the result
          # 3. Add metrics relating to this event to a Namespace with the current model name
          # 4. Return the operation result so the enclosing method can return it
          def self.record(event, model, &operation)
            result = nil
            Fiveruns::Tuneup.tracking_model model do |name|
              time = Fiveruns::Tuneup.stopwatch { result = yield }
              Fiveruns::Tuneup.metrics_in :model, Fiveruns::Tuneup.context, [:name, name] do |metrics|
                metrics[event.to_s.pluralize.to_sym] += 1
                metrics["#{event}_time".to_sym] += time
                # TODO: metrics["#{event}_errors".to_sym]
              end
            end
            result
          end
          
          def self.record_connection(model)
            result = yield
            Fiveruns::Tuneup.metrics_in nil, Fiveruns::Tuneup.context, nil do |metrics|
              metrics[:active_conns] = model.active_connections.size
            end
            connections = model.active_connections
            adapter     = connections[connections.keys.first].class
            if adapter != NilClass && !Fiveruns::Tuneup.instrumented_adapters.include?(adapter)
              instrument_adapter(adapter)
            end
            result
          end
          
          def self.instrument_adapter(adapter)
            adapter.send(:include, AdapterMethods)
            Fiveruns::Tuneup.instrumented_adapters << adapter
          end
            
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods, ClassMethods
          end
          
          module AdapterMethods
            
            def self.included(base)
              Fiveruns::Tuneup.instrument base, InstanceMethods
            end
                        
            module InstanceMethods
              
              def begin_db_transaction_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :tx_starts do
                  begin_db_transaction_without_fiveruns_manage(*args, &block)
                end
              end
              
              def commit_db_transaction_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :tx_commits do
                  commit_db_transaction_without_fiveruns_manage(*args, &block)
                end
              end
              
              def rollback_db_transaction_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :tx_aborts do
                  rollback_db_transaction_without_fiveruns_manage(*args, &block)
                end
              end
              
              def initialize_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :creates do
                  initialize_without_fiveruns_manage(*args, &block)
                end
              end
              
              def disconnect_with_fiveruns_manage!(*args, &block)
                Fiveruns::Tuneup.tally :disconnects do
                  disconnect_without_fiveruns_manage!(*args, &block)
                end
              end

            end
          end
               
          module ClassMethods
            def establish_connection_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record_connection self do
                establish_connection_without_fiveruns_manage(*args, &block)
              end
            end
            def retrieve_connection_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record_connection self do
                retrieve_connection_without_fiveruns_manage(*args, &block)
              end
            end
            def remove_connection_with_fiveruns_manage(*args, &block)
              result = remove_connection_without_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup.metrics_in nil, Fiveruns::Tuneup.context, nil do |metrics|
                metrics[:removes] += 1
                metrics[:active_conns] = self.active_connections.size
              end
              result
            end
            
            #
            # FINDS
            #
            
            def find_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :find,  self do
                find_without_fiveruns_manage(*args, &block)
              end
            end
            def find_by_sql_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :find, self do
                find_by_sql_without_fiveruns_manage(*args, &block)
              end
            end
            
            #
            # CREATE
            #
            
            def create_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :create, self do
                create_without_fiveruns_manage(*args, &block)
              end
            end
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self do
                update_without_fiveruns_manage(*args, &block)
              end
            end
            def update_all_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self do
                update_all_without_fiveruns_manage(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                destroy_without_fiveruns_manage(*args, &block)
              end
            end
            def destroy_all_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                destroy_all_without_fiveruns_manage(*args, &block)
              end
            end
            def delete_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                delete_without_fiveruns_manage(*args, &block)
              end
            end
            def delete_all_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self do
                delete_all_without_fiveruns_manage(*args, &block)
              end
            end
          end
          module InstanceMethods
            
            #
            # UPDATES
            #
            
            def update_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                update_without_fiveruns_manage(*args, &block)
              end
            end
            def save_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                save_without_fiveruns_manage(*args, &block)
              end
            end
            def save_with_fiveruns_manage!(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :update, self.class do
                save_without_fiveruns_manage!(*args, &block)
              end
            end
            
            #
            # DELETES
            #
            
            def destroy_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup::Instrumentation::ActiveRecord::Base.record :delete, self.class do
                destroy_without_fiveruns_manage(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end