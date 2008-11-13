module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionView
        module Base
                    
          BASIC_TEMPLATE_PATH = File.join(RAILS_ROOT, 'app', 'views')           
          
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end

          def self.normalize_path(path)
            return path unless path
            if path[0, BASIC_TEMPLATE_PATH.size] == BASIC_TEMPLATE_PATH
              path[(BASIC_TEMPLATE_PATH.size + 1)..-1]
            else
              if (components = path.split(File::SEPARATOR)).size > 2
                components[-2, 2].join(File::SEPARATOR)
              else
                components.join(File::SEPARATOR)
              end
            end
          end
          
          module InstanceMethods
            def render_file_with_fiveruns_tuneup(path, *args, &block)
              name = Fiveruns::Tuneup::Instrumentation::ActionView::Base.normalize_path(path)
              Fiveruns::Tuneup.step "Render file #{name}", :view do
                render_file_without_fiveruns_tuneup(path, *args, &block)
              end
            end
            def update_page_with_fiveruns_tuneup(*args, &block)
              path = block.to_s.split('/').last.split(':').first rescue ''
              name = Fiveruns::Tuneup::Instrumentation::ActionView::Base.normalize_path(path)
              Fiveruns::Tuneup.step "Render page update #{name}", :view do
                update_page_without_fiveruns_tuneup(*args, &block)
              end
            end
            def render_with_fiveruns_tuneup(*args, &block)
              record = true
              options = args.first || {}
              path = case options
              when String
                # Pre-Rails 2.1, don't record this as it causes duplicate records 
                if Fiveruns::Tuneup::Version.rails < Fiveruns::Tuneup::Version.new(2,1,0)
                  record = false
                else
                  "Render #{options}"                  
                end
              when :update
                name = block.to_s.split('/').last.split(':').first rescue ''
                "Render page update #{name}"
              when Hash
                if options[:file]
                  "Render #{options[:file]}"
                elsif options[:partial]
                  record = false
                elsif options[:inline]
                  "Render inline"
                elsif options[:text]
                  "Render text"
                end
              end
              path ||= 'Render'
              
              if record
                Fiveruns::Tuneup.step path, :view do
                  render_without_fiveruns_tuneup(*args, &block)
                end
              else
                render_without_fiveruns_tuneup(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end