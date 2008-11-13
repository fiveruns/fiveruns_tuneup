module Fiveruns
  module Tuneup
    module Instrumentation
      
      def self.install!
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
              
      def self.instrument(target, *mods)
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
      
      def self.instrument_action_methods(controller)
        klass = controller.class
        actions_for(klass).each do |meth|
          format = alias_format_for(meth)
          next if controller.respond_to?(format % :with, true)
          wrap(klass, format, meth, "Invoke #{meth} action", :controller)
        end
      end
      
      def self.instrument_filters(controller)
        klass = controller.class
        filters_for(klass).each do |filter|
          format = alias_format_for(name_of_filter(filter))
          next if controller.respond_to?(format % :with, true)
          wrap(klass, format, name_of_filter(filter), "#{filter.type.to_s.titleize} filter #{name_of_filter(filter)}", :controller)
        end
      end
      
      #######
      private
      #######
      
      def self.wrap(klass, format, meth, name, layer)
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
      
      def self.alias_format_for(name)
        name.to_s =~ /^(.*?)(\?|!|=)$/ ? "#{$1}_%s_fiveruns_tuneup#{$2}" : "#{name}_%s_fiveruns_tuneup"
      end
      
      def self.actions_for(klass)
        klass.action_methods.reject { |meth| meth.to_s.include?('fiveruns') }
      end
      
      def self.filters_for(klass)
        klass.filter_chain.select { |f| name_of_filter(f).is_a?(Symbol) }
      end
      
      def self.name_of_filter(filter)
        if filter.respond_to?(:filter)
          filter.filter
        else
          filter.method
        end
      end

      def self.path_to_constant_name(path)
        parts = path.split(File::SEPARATOR)
        parts.map(&:camelize).join('::').sub('Cgi', 'CGI')
      end
        
    end
  end
end
      