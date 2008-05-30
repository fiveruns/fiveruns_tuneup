require File.dirname(__FILE__) << "/tuneup/step"

require 'digest/sha1'
require 'yaml'
require 'zlib'
require File.dirname(__FILE__) << '/tuneup/step'

module Fiveruns
  module Tuneup
    
    LOGGER = Logger.new('log/tuneup.log')
        
    class << self
      
      include Fiveruns::Tuneup::Urls
      include Fiveruns::Tuneup::AssetTags
      include Fiveruns::Tuneup::Runs
      include Fiveruns::Tuneup::Instrumentation::Utilities
      include Fiveruns::Tuneup::Environment
      include Fiveruns::Tuneup::Schema
      
      attr_writer :collecting
      attr_accessor :running
      attr_reader :trend
      
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
          @trend = nil
          @environment = environment
          yield
          log :info, "Persisting for #{request.url} using stub #{stub(request.url)}"
          data = @stack.shift
          persist(generate_run_id(request.url, data.time), @environment, schemas, data)
        elsif !@running
          # Plugin displaying the data
          # TODO: Support targeted selection (for historical run)
          if request.parameters['uri']
            last_id = last_run_id_for(request.parameters['uri'])
            log :info, "Retrieved last run id of #{last_id} for #{request.parameters['uri']} using stub #{stub(request.parameters['uri'])}"
            if last_id && (data = retrieve_run(last_id))
              @stack = [data]
              @trend = trend_for(last_id)
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
      
      def start
        log :info, "Starting..."
        install_instrumentation
        log :debug, "Using collector at #{collector_url}"
        log :debug, "Using frontend at #{frontend_url}"
      end
            
      def log(level, text)
        LOGGER.send(level, "FiveRuns TuneUp (v#{Fiveruns::Tuneup::Version::STRING}): #{text}")
      end
      
      #######
      private
      #######
      
      def clear_stack
        @stack = nil
        @exclusion_stack = nil
      end
      
    end
    
  end
end
  