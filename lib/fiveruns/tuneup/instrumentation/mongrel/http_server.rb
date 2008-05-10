module Fiveruns
  module Tuneup
    module Instrumentation
      module Mongrel
        module HttpServer
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            # FIXME: this probe is firing but not storing anything. WTF?
            def process_client_with_fiveruns_manage(*args, &block)
              result = process_client_without_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup.metrics_in :mongrel, nil, [:name, self.port] do |metrics|
                metrics[:workers] = self.workers.list.length
              end
              result
            end
          end
        end
      end
    end
  end
end