module Fiveruns
  module Tuneup
    module Environment
      
      def environment
        {
          'application_name' => application_name,
          'rails_env' => rails_env,
          'rails_version' => rails_version
        }
      end
      
      def rails_env
        RAILS_ENV || 'development'
      end
      
      def rails_version
        ::Rails::VERSION::STRING rescue 'unknown Rails version'
      end
      
      def application_name
        app_name = RAILS_ROOT.split('/').last
        return app_name unless app_name == 'current'             
        File.join(RAILS_ROOT, '..').split('/').last
      end
      
    end
  end
end