module Fiveruns
  module Tuneup
    module Instrumentation

      class Error < ::NameError; end

      def install_instrumentation
        log :debug, "Installing instrumentation..."
        Dir[File.dirname(__FILE__) << "/../../../instrumentation/**/*.rb"].each do |file|
          eval File.read(file)
        end
      end
      
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
            handle_exclusions_in step do
              step.time = stopwatch { result = yield(sql) }
            end
            stack.pop
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
      
      def instrumenting(name, level, &block)
        constant = name.is_a?(String) ? (name.constantize rescue nil) : name
        unless constant
          log :warn, "Could not instrument #{name} (#{level})"
          return
        end
        target = level == :instance ? constant : (class << constant; self; end)
        mod = Module.new(&block)
        target.send(:include, mod)
        extracted_from(mod.instance_methods).each do |meth|
          Fiveruns::Manage.log :debug, "Wrapping #{target} #{meth}"
          format = chain_format(meth)
          unless (target.instance_methods + target.private_instance_methods).include?(format % :without)
            target.alias_method_chain meth, :fiveruns_manage
          end
        end
      end

      def chain_format(meth)
        meth.to_s =~ /^(.*?)(\?|!|=)$/ ? "#{$1}_%s_fiveruns_manage#{$2}" : "#{meth}_%s_fiveruns_manage"
      end

      def extracted_from(meths)
        meths.grep(/_with_fiveruns_manage/).map { |meth| meth.sub('_with_fiveruns_manage', '') }
      end
        
    end
  end
end
      