require File.dirname(__FILE__) << "/tuneup/step"

require 'yaml'
require 'zlib'

module Fiveruns
  module Tuneup
        
    class << self
      
      include Fiveruns::Tuneup::Urls
      include Fiveruns::Tuneup::Runs
      include Fiveruns::Tuneup::AssetTags
      include Fiveruns::Tuneup::Instrumentation::Utilities
      
      attr_writer :collecting
      attr_accessor :running
      
      def run(controller, request)
        @running = (!controller.is_a?(TuneupController) && !request.xhr?)
        result = nil
        log :info, "RECORDING: #{recording? ? :true : :false}"
        record do
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
      
      def record
        if recording?
          @stack = [Fiveruns::Tuneup::RootStep.new]
        elsif !@running
          # Plugin displaying the data
          data = last_run
          if data
            @stack = [data]
          else
            clear_stack
          end
        end
        yield
        persist @stack.shift if recording?
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
        reset!
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
  