module Fiveruns
  module Tuneup
    module Instrumentation
      module Utilities
        
        def stopwatch
          start = Time.now.to_f
          yield
          (Time.now.to_f - start) * 1000
        end

        def step(name, layer=nil, link=true, sql=nil, explain=nil, &block)
          if recording?
            result = nil
            caller_line = caller.detect { |l| l.include?(RAILS_ROOT) && l !~ /tuneup|vendor\/rails/ } if link
            file, line = caller_line ? caller_line.split(':')[0, 2] : [nil, nil]
            line = line.to_i if line
            returning ::Fiveruns::Tuneup::Step.new(name, layer, file, line, sql, explain, &block) do |s|
              stack.last << s
              stack << s
              s.time = stopwatch { result = yield(sql) }
              stack.pop
            end
            result
          else
            yield(sql)
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
        
        #######
        private
        #######

        def install_instrumentation
          instrumentation_path = File.dirname(__FILE__)
          Dir[File.join(instrumentation_path, '/*/**/*.rb')].each do |filename|
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
end
      