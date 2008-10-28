deps = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : Dependencies
deps.load_paths.unshift File.dirname(__FILE__)