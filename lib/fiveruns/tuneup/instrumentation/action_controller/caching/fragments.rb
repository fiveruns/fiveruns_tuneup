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
              def write_fragment_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :frag_caches do
                  write_fragment_without_fiveruns_manage(*args, &block)
                end
              end
              def expire_fragment_with_fiveruns_manage(*args, &block)
                Fiveruns::Tuneup.tally :frag_expires do
                  expire_fragment_without_fiveruns_manage(*args, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end