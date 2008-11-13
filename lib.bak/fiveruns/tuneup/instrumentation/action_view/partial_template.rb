module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionView
        module PartialTemplate       
          
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          
          def self.relevant?
            Fiveruns::Tuneup::Version.rails < Fiveruns::Tuneup::Version.new(2,1,0) ? false : true
          end
          
          module InstanceMethods

            def render_with_fiveruns_tuneup(*args, &block)
              Fiveruns::Tuneup.step "Render partial #{path}", :view do
                render_without_fiveruns_tuneup(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end