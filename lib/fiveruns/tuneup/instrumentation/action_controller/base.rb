module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module Base
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def process_with_fiveruns_tuneup(request, response, *args, &block)
              Fiveruns::Tuneup.run(self, request) do
                action = (request.parameters['action'] || 'index').to_s
                result = Fiveruns::Tuneup.step "#{action.capitalize} action in #{self.class.name}", :controller, false do
                  process_without_fiveruns_tuneup(request, response, *args, &block)
                end
                if !request.xhr? && response.content_type == 'text/html'
                  Fiveruns::Tuneup.add_asset_tags_to(response.body)
                end
                result
              end
            end
          end
        end
      end
    end
  end
end