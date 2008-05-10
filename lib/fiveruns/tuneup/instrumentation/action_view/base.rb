module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionView
        module Base
                    
          BASIC_TEMPLATE_PATH = File.join(RAILS_ROOT, 'app', 'views')           
          
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          
          def self.record(path, reset_bytes=false)
            if path
              result = nil
              time = Fiveruns::Tuneup.stopwatch { result = yield }
              bytes = result ? result.length : 0
              if reset_bytes
                Fiveruns::Tuneup.bytes_this_request = bytes
              else
                Fiveruns::Tuneup.bytes_this_request += bytes
              end
              normalized_path = self.normalize_path(path.to_s)
              Fiveruns::Tuneup.metrics_in :view, Fiveruns::Tuneup.context, [:name, normalized_path] do |metrics|
                metrics[:bytes] += bytes
                metrics[:proc_time] = time
                metrics[:reqs] += 1
              end
              result
            else
              yield # Just execute the method
            end
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
          
          def self.extract_partial_path(path)
            case path
            when String, Symbol, NilClass
              path.to_s
            when Array, 
                 ::ActiveRecord::Associations::AssociationCollection, 
                 ::ActiveRecord::Associations::HasManyThroughAssociation
              return nil unless path.first
              ::ActionController::RecordIdentifier.partial_path(path.first)
            end
          end
          
          module InstanceMethods
            def render_file_with_fiveruns_manage(path, *args, &block)
              Fiveruns::Tuneup::Instrumentation::ActionView::Base.record path, true do
                render_file_without_fiveruns_manage(path, *args, &block)
              end
            end
            def update_page_with_fiveruns_manage(*args, &block)
              path = block.to_s.split('/').last.split(':').first rescue ':update'
              Fiveruns::Tuneup::Instrumentation::ActionView::Base.record path do
                update_page_without_fiveruns_manage(*args, &block)
              end
            end
            def render_with_fiveruns_manage(*args, &block)
              record = true
              options = args.first || {}
              path = case options
              when String
                options
              when :update
                block.to_s.split('/').last.split(':').first rescue ':update'
              when Hash
                if options[:file]
                  options[:file].to_s
                elsif options[:partial]
                  # Don't record this as it causes duplicate records
                  record = false
                #   Fiveruns::Tuneup::Instrumentation::ActionView::Base.extract_partial_path(options[:partial])
                elsif options[:inline]
                  ':inline'
                elsif options[:text]
                  ':text'
                end
              end
              path ||= '(unknown)'
              
              if record
                Fiveruns::Tuneup::Instrumentation::ActionView::Base.record path do
                  render_without_fiveruns_manage(*args, &block)
                end
              else
                render_without_fiveruns_manage(*args, &block)
              end
            end
            
            # Instrumenting these causes duplicate records for every partial
            # rendered. You really only need to instrument ++render++ when its 
            # passed a string
            
            # def render_partial_collection_with_fiveruns_manage(path, *args, &block)
            #   Fiveruns::Tuneup::Instrumentation::ActionView::Base.record path, true do
            #     render_partial_collection_without_fiveruns_manage(path, *args, &block)
            #   end
            # end
            # def render_partial_with_fiveruns_manage(path, *args, &block)
            #   partial_path = Fiveruns::Tuneup::Instrumentation::ActionView::Base.extract_partial_path(path)
            #   
            #   Fiveruns::Tuneup::Instrumentation::ActionView::Base.record partial_path do
            #     render_partial_without_fiveruns_manage(path, *args, &block)
            #   end
            # end
          end
        end
      end
    end
  end
end