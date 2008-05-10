module Fiveruns
  module Tuneup
    module Instrumentation
      module ActiveRecord
        module ActiveRecordError
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def initialize_with_fiveruns_manage(*args, &block)
              result = initialize_without_fiveruns_manage(*args, &block)
              error_name = case self
              when ::ActiveRecord::RecordNotFound
                :find_errs
              when ::ActiveRecord::RecordNotSaved, 
                   ::ActiveRecord::StaleObjectError, 
                   ::ActiveRecord::ReadOnlyRecord, 
                   ::ActiveRecord::Transactions::TransactionError, 
                   ::ActiveRecord::RecordInvalid, 
                   ::ActiveRecord::HasManyThroughCantAssociateNewRecords, 
                   ::ActiveRecord::HasManyThroughCantDissociateNewRecords, 
                   ::ActiveRecord::ReadOnlyAssociation
                # Generically use update_errs, since we can't tell if we're saving a record
                # TODO: Determine record state
                :update_errs
              when ::ActiveRecord::StatementInvalid, 
                   ::ActiveRecord::PreparedStatementInvalid
                # :generic_errs
              else # Unknown children of ActiveRecordError
                # :generic_errs
              end
              if error_name
                model_name = Fiveruns::Tuneup.current_model
                Fiveruns::Tuneup.tally error_name, :model, Fiveruns::Tuneup.context, [:name, model_name]
              end
              result
            end
          end
        end
      end
    end
  end
end