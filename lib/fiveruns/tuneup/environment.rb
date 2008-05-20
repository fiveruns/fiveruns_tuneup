module Fiveruns
  module Tuneup
    module Environment
      
      def environment
        {
          'rails_env' => rails_env,
          'rails_version' => rails_version
        }
      end
      
      def rails_env
        RAILS_ENV || 'development'
      end
      
      def rails_version
        ::Rails::VERSION::STRING rescue 'unknown Rails version'
#        "#{::Rails::VERSION::MAJOR}.#{::Rails::VERSION::MINOR}.#{::Rails::VERSION::TINY}"
      end
      
    end
  end
end