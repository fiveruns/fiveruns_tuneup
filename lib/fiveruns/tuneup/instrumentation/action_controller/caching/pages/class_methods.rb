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
                def cache_page_with_fiveruns_manage(*args, &block)
                  Fiveruns::Tuneup.tally :pages_caches do
                    cache_page_without_fiveruns_manage(*args, &block)
                  end
                end
                def expire_page_with_fiveruns_manage(*args, &block)
                  Fiveruns::Tuneup.tally :pages_expires do
                    expire_page_without_fiveruns_manage(*args, &block)
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