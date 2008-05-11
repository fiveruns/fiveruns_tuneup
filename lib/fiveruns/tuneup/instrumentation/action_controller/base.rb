module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module Base
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def process_with_fiveruns_tuneup(request, *args, &block)
              Fiveruns::Tuneup.run(self.class != TuneupController) do
                action = (request.parameters['action'] || 'index').to_s
                Fiveruns::Tuneup.step "Action: #{self.class.name}##{action}", :controller do
                  process_without_fiveruns_tuneup(request, *args, &block) 
                end
              end
            end
          end
        end
      end
    end
  end
end