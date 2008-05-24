require File.dirname(__FILE__) << "/tuneup/step"

require 'digest/sha1'
require 'yaml'
require 'zlib'

module Fiveruns
  module Tuneup
        
    class << self
      
      include Fiveruns::Tuneup::Urls
      include Fiveruns::Tuneup::AssetTags
      include Fiveruns::Tuneup::Runs
      include Fiveruns::Tuneup::Instrumentation::Utilities
      include Fiveruns::Tuneup::Environment
      include Fiveruns::Tuneup::Schema
      
      attr_writer :collecting
      attr_accessor :running
      attr_accessor :current_run_id
      
      def run(controller, request)
        @running = (!controller.is_a?(TuneupController) && !request.xhr?)
        result = nil
        record controller, request do
          result = yield
        end
        @running = false
        result
      end
      
      def collecting
        if defined?(@collecting)
          @collecting
        else
          @collecting = true
        end
      end
      
      def record(controller, request)
        if recording?
          @stack = [Fiveruns::Tuneup::RootStep.new]
          @environment = environment
          self.current_run_id = generate_run_id(request.url)
          yield
          log :info, "Persisting for #{request.url} using stub #{stub(request.url)}"
          persist(self.current_run_id, @environment, schemas, @stack.shift)
          self.current_run_id = nil
        elsif !@running
          # Plugin displaying the data
          # TODO: Support targeted selection (for historical run)
          if request.parameters['uri']
            last_id = last_run_id_for(request.parameters['uri'])
            log :info, "Retrieved last run id of #{last_id} for #{request.parameters['uri']} using stub #{stub(request.parameters['uri'])}"
            if last_id && (data = retrieve_run(last_id))
              @stack = [data]
            else
              log :debug, "No stack found"
              clear_stack
            end
          else
            clear_stack
          end
          yield            
        else
          yield
        end
        clear_stack
      end
      
      def recording?
        @running && @collecting
      end
      
      def stack
        @stack ||= []
      end
      
      def start
        log :info, "Starting..."
        reset! unless ENV['FIVERUNS_TUNEUP_RETAIN']
        install_instrumentation
        log :debug, "Using collector at #{collector_url}"
        log :debug, "Using frontend at #{frontend_url}"
      end
            
      def log(level, text)
        RAILS_DEFAULT_LOGGER.send(level, "FiveRuns TuneUp (v#{Fiveruns::Tuneup::Version::STRING}): #{text}")
      end
      
      #######
      private
      #######

      # Remove all runs from this session
      def reset!
        FileUtils.rm_rf run_dir
      rescue
        # Nothing to remove, ignore
      end
      
      def clear_stack
        @stack = []
      end
      
    end
    
  end
end
  