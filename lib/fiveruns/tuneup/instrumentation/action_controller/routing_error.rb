module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module RoutingError
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def initialize_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup.tally :routing_errs, nil, nil, nil do
                initialize_without_fiveruns_manage(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end