module Fiveruns
  module Tuneup
    module Instrumentation
      module Utilities
        
        def stack
          @stack ||= []
        end

        def exclusion_stack
          @exclusion_stack ||= [0]
        end
        
        def custom_methods
          @custom_methods ||= {}
        end
        
        def add_custom_methods(target, *methods)
          custom_methods[target] = [] unless custom_methods.key?(target)
          custom_methods[target].push(*methods)
        end
        
        def stopwatch
          start = Time.now.to_f
          yield
          (Time.now.to_f - start) * 1000
        end
        
        def exclude
          result = nil
          exclusion_stack[-1] += stopwatch { result = yield }
          result
        end

        def step(name, layer=nil, link=true, sql=nil, table_name=nil, &block)
          if recording?
            result = nil
            caller_line = caller.detect { |l| l.include?(RAILS_ROOT) && l !~ /tuneup|vendor\/rails/ } if link
            file, line = caller_line ? caller_line.split(':')[0, 2] : [nil, nil]
            line = line.to_i if line
            returning ::Fiveruns::Tuneup::Step.new(name, layer, file, line, sql, &block) do |step|
              step.table_name = table_name
              stack.last << step
              stack << step
              begin
                handle_exclusions_in step do
                  step.time = stopwatch { result = yield(sql) }
                end
              ensure
                stack.pop
              end
            end
            result
          else
            yield(sql)
          end
        end
        
        # Handle removal of excluded time from total for this step, and
        # bubble the value up for removal from the parent step
        def handle_exclusions_in(step)
          exclusion_stack << 0
          yield # Must set +step.time+
          time_to_exclude = exclusion_stack.pop
          step.time -= time_to_exclude
          exclusion_stack[-1] += time_to_exclude unless exclusion_stack.blank?
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
        
        def instrument_action_methods(controller)
          klass = controller.class
          actions_for(klass).each do |meth|
            format = alias_format_for(meth)
            next if controller.respond_to?(format % :with, true)
            wrap(klass, format, meth, "Invoke #{meth} action", :controller)
          end
        end
        
        def instrument_filters(controller)
          klass = controller.class
          filters_for(klass).each do |filter|
            format = alias_format_for(name_of_filter(filter))
            next if controller.respond_to?(format % :with, true)
            wrap(klass, format, name_of_filter(filter), "#{filter.type.to_s.titleize} filter #{name_of_filter(filter)}", :controller)
          end
        end
        
        def instrument_custom_methods
          custom_methods.each do |meth_target, meths|
            lineage = meth_target.ancestors
            layer = if lineage.include?(ActionController::Base)
              :controller
            elsif lineage.include?(ActiveRecord::Base)
              :model
            elsif lineage.include?(ActionView::Base)
              :view
            else
              :other
            end
            meths.each do |meth|
              format = alias_format_for(meth)
              wrap(meth_target, format, meth, "Method #{meth}", layer)
            end
          end
        end
        
        #######
        private
        #######
        
        def wrap(klass, format, meth, name, layer)
          return if klass.instance_methods.include?(format % :with)
          text = <<-EOC
            def #{format % :with}(*args, &block)
              Fiveruns::Tuneup.step "#{name}", :#{layer} do
                #{format % :without}(*args, &block)
              end
            end
            alias_method_chain :#{meth}, :fiveruns_tuneup
          EOC
          begin
            klass.class_eval text
          rescue SyntaxError => e
            # XXX: Catch-all for reports of oddly-named methods affecting dynamically generated code
            log :warn, %[Bad syntax wrapping #{klass}##{meth}, "#{name}"]
          end
        end
        
        def alias_format_for(name)
          name.to_s =~ /^(.*?)(\?|!|=)$/ ? "#{$1}_%s_fiveruns_tuneup#{$2}" : "#{name}_%s_fiveruns_tuneup"
        end
        
        def actions_for(klass)
          klass.action_methods.reject { |meth| meth.to_s.include?('fiveruns') }
        end
        
        def filters_for(klass)
          klass.filter_chain.select { |f| name_of_filter(f).is_a?(Symbol) }
        end
        
        def name_of_filter(filter)
          if filter.respond_to?(:filter)
            filter.filter
          else
            filter.method
          end
        end

        def install_instrumentation
          instrumentation_path = File.dirname(__FILE__)
          Dir[File.join(instrumentation_path, '/*/**/*.rb')].each do |filename|
            constant_path = filename[(instrumentation_path.size + 1)..-4]
            constant_name = path_to_constant_name(constant_path)
            
            instrumentation = "Fiveruns::Tuneup::Instrumentation::#{constant_name}".constantize            
            next if instrumentation.respond_to?(:relevant?) && !instrumentation.relevant?
              
            if (constant = constant_name.constantize rescue nil)             
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
      