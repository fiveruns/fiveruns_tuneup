module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module Caching
          module Pages
            module ClassMethods
              def self.included(base)
                Fiveruns::Tuneup.instrument base, InstanceMethods
              end
              module InstanceMethods
                def cache_page_with_fiveruns_tuneup(*args, &block)
                  Fiveruns::Tuneup.step "Cache page", :controller do
                    cache_page_without_fiveruns_tuneup(*args, &block)
                  end
                end
                def expire_page_with_fiveruns_tuneup(*args, &block)
                  Fiveruns::Tuneup.step "Expire cached page", :controller do
                    expire_page_without_fiveruns_tuneup(*args, &block)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end