module Fiveruns
  module Tuneup
    module Instrumentation
      module CGI
        module Session
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def initialize_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup.step "Create session" do
                initialize_without_fiveruns_tuneup(*args, &block)
              end
            end
            def close_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup.step "Close session" do
                close_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup.step "Delete session" do
                delete_without_fiveruns_tuneup(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end