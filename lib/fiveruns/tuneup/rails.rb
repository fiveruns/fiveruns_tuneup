require 'ostruct'

require 'fiveruns/tuneup/rails/routing'

module Fiveruns
  module Tuneup
    
    module Rails
      
      def self.start
        if start?
          configure!
          route!
          copy_assets!
          instrument!
        end
      end
      
      def self.start?
        configuration.environments.map(&:to_s).include?(RAILS_ENV.to_s)
      end
      
      def self.configure
        yield configuration
      end
      
      def self.configuration
        @configuration ||= OpenStruct.new(defaults)
      end

      
      def self.configure!
        Fiveruns::Tuneup::Run.directory = configuration.run_directory
        Fiveruns::Tuneup::Run.api_key  =  configuration.api_key
        Fiveruns::Tuneup::Run.environment.update(_environment)
        Fiveruns::Tuneup.javascripts_path = FiverunsTuneupMerb.public_dir_for('javascripts')
        Fiveruns::Tuneup.stylesheets_path = FiverunsTuneupMerb.public_dir_for('stylesheets')
      end
      
      def self.route!
        require 'dispatcher'
        Fiveruns::Tuneup::Rails::Routing.install
        ::Dispatcher.to_prepare :tuneup_controller_filters do
          ::FiverunsTuneupRailsController.filter_chain.clear
          ::FiverunsTuneupRailsController.before_filter :find_config, :except => :index
        end
      end
      
      def self.copy_assets!
        root = File.dirname(__FILE__) << '/../../..'
        destination = File.join(RAILS_ROOT, 'public', 'fiveruns_tuneup_rails')
        FileUtils.rm_rf(destination) rescue nil
        FileUtils.cp_r(File.join(root, 'public'), destination)
      end
      
      def instrument!
        Instrumentation.install!
      end
      
      def self.defaults
        {
          :api_key => nil,
          :application_name => File.dirname(RAILS_ROOT),
          :environments => %(development),
          :run_directory => File.join(RAILS_ROOT, 'tmp', 'tuneup', 'runs'),
          :stylesheets_directory =>  File.join(RAILS_ROOT, 'public', 'fiveruns_tuneup_rails', 'stylesheets'),
          :javascripts_directory =>  File.join(RAILS_ROOT, 'public', 'fiveruns_tuneup_rails', 'javascripts')
        }
      end
      
      def self.environment
        {
          :application_name => configuration.application_name,
          :framework => 'rails',
          :framework_version => Rails::VERSION::STRING,
          :framework_env => RAILS_ENV
        }
      end
      
    end
    
  end
end