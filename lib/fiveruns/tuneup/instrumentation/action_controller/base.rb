module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionController
        module Base
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def process_with_fiveruns_manage(request, *args, &block)
              result = nil
              action = (request.parameters['action'] || 'index').to_s
              Fiveruns::Tuneup.context = context = [:controller, (controller = self.class.name), :action, action]
              time = Fiveruns::Tuneup.stopwatch { result = process_without_fiveruns_manage(request, *args, &block) }
              Fiveruns::Tuneup.metrics_in :action, context, [:name, action] do |metrics|
                metrics[:reqs] += 1
                metrics[:proc_time] += time
                metrics[:bytes] += Fiveruns::Tuneup.bytes_this_request
              end
              Fiveruns::Tuneup.metrics_in :controller, context, [:name, controller] do |metrics|
                metrics[:reqs] += 1
                metrics[:proc_time] += time
                metrics[:bytes] += Fiveruns::Tuneup.bytes_this_request
              end
              Fiveruns::Tuneup.context = nil
              Fiveruns::Tuneup.bytes_this_request = 0
              result
            end
            def rescue_action_with_fiveruns_manage(*args, &block)
              result = rescue_action_without_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup.tally :rescues, :action, Fiveruns::Tuneup.context, [:name, Fiveruns::Tuneup.action_in_context]
              Fiveruns::Tuneup.tally :rescues, :controller, Fiveruns::Tuneup.context, [:name, Fiveruns::Tuneup.controller_in_context]
              result
            end
          end
        end
      end
    end
  end
end