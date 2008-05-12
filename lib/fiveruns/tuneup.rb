require File.dirname(__FILE__) << "/tuneup/step"

require 'yaml'
require 'zlib'

module Fiveruns
  module Tuneup
    
    class << self
      
      attr_writer :collecting
      attr_accessor :running
      attr_accessor :stack
      
      def run(allow=true)
        @running = allow
        result = nil
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
          if data = last_run
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
      
      # Remove all runs from this session
      def reset!
        FileUtils.rm_rf run_dir
      rescue
        # Nothing to remove, ignore
      end
      
      def clear_stack
        @stack = []
      end
      
      def start
        log :info, "Starting..."
        reset!
        install_instrumentation
        log :debug, "Using collector at #{collector_url}"
        log :debug, "Using frontend at #{frontend_url}"
      end
      
      def stopwatch
        start = Time.now.to_f
        yield
        (Time.now.to_f - start) * 1000
      end
      
      def step(name, layer=nil, link=true, &block)
        if recording?
          result = nil
          caller_line = caller.detect { |l| l.include?(RAILS_ROOT) && l !~ /tuneup|vendor\/rails/ } if link
          file, line = caller_line ? caller_line.split(':')[0, 2] : [nil, nil]
          line = line.to_i if line
          returning ::Fiveruns::Tuneup::Step.new(name, layer, file, line, &block) do |s|
            stack.last << s
            stack << s
            s.time = stopwatch { result = yield }
            stack.pop
          end
          result
        else
          yield
        end
      end

      def instrument(target, *mods)
        mods.each do |mod|
          # Change target for 'ClassMethods' module
          real_target = mod.name.demodulize == 'ClassMethods' ? (class << target; self; end) : target
          real_target.__send__(:include, mod)
          # Find all the instrumentation hooks and chain them in
          mod.instance_methods.each do |meth|
            name = meth.to_s.sub('_with_fiveruns_tuneup', '')
            real_target.alias_method_chain(name, :fiveruns_tuneup) rescue nil
          end
        end
      end
      
      def instrumented_adapters
        @instrumented_adapters ||= []
      end
      
      def log(level, text)
        RAILS_DEFAULT_LOGGER.send(level, "FiveRuns TuneUp (v#{Fiveruns::Tuneup::Version::STRING}): #{text}")
      end
      
      def run_dir
        @run_dir ||= File.join(RAILS_ROOT, 'tmp', 'fiveruns_tuneup', 'runs')
      end
      
      def last_run
        filename = run_files.last
        load_from_file(filename) if filename
      end
      
      def load_from_file(filename)
        decompressed = Zlib::Inflate.inflate(File.open(filename, 'rb') { |f| f.read })        
        YAML.load(decompressed)
      end
      
      def run_files
        Dir[File.join(run_dir, '*.yml.gz')]
      end
      
      def collector_url
        @collector_url ||= begin
          url = ENV['TUNEUP_COLLECTOR'] || 'http://tuneup-collector.fiveruns.com'
          url = "http://#{url}" unless url =~ /^http/
          url
        end
      end
      
      def frontend_url
        @frontend_url ||= begin
          url = ENV['TUNEUP_FRONTEND'] || 'https://tuneup.fiveruns.com'
          url = "http://#{url}" unless url =~ /^http/
          url
        end
      end
      
      #######
      private
      #######

      def install_instrumentation
        instrumentation_path = File.join(File.dirname(__FILE__) << "/tuneup/instrumentation")
        Dir[File.join(instrumentation_path, '/**/*.rb')].each do |filename|
          constant_path = filename[(instrumentation_path.size + 1)..-4]
          constant_name = path_to_constant_name(constant_path)
          if (constant = constant_name.constantize rescue nil)
            instrumentation = "Fiveruns::Tuneup::Instrumentation::#{constant_name}".constantize
            constant.__send__(:include, instrumentation)
          else
            log :debug, "#{constant_name} not found; skipping instrumentation."
          end
        end
      end
      
      def path_to_constant_name(path)
        parts = path.split(File::SEPARATOR)
        parts.map(&:camelize).join('::').sub('Cgi', 'CGI')
      end
      
      def persist(data)
        FileUtils.mkdir_p run_dir
        compressed = Zlib::Deflate.deflate(data.to_yaml)        
        File.open(File.join(run_dir, "#{now}.yml.gz"), 'wb') { |f| f.write compressed }
      end
      
      def now
        Time.now.to_f
      end
      
    end
    
  end
end
  