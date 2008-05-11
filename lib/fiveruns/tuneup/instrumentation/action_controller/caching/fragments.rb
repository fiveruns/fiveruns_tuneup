module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module Caching
          module Fragments
            def self.included(base)
              Fiveruns::Tuneup.instrument base, InstanceMethods
            end
            module InstanceMethods
              def write_fragment_with_fiveruns_tuneup(*args, &block)
                Fiveruns::Tuneup.step "Cache fragment", :controller do
                  write_fragment_without_fiveruns_tuneup(*args, &block)
                end
              end
              def expire_fragment_with_fiveruns_tuneup(*args, &block)
                Fiveruns::Tuneup.step "Expire fragment cache", :controller do
                  expire_fragment_without_fiveruns_tuneup(*args, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end