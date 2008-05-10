module Fiveruns
  module Tuneup
    
    class << self
      
      attr_accessor :collecting
      
      def data
        @data ||= RootStep.new
      end
      
      def stack
        @stack ||= [data]
      end
      
      def clear
        @data = @stack = nil
      end
      
      def start
        log :info, "Starting..."
        install_instrumentation
      end
      
      def step(*args)
        returning Step.new(*args, &block) do |s|
          stack.last << s
          if block_given?
            stack << s
            yield
            stack.pop
          end
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
      
    end
    
  end
end
  