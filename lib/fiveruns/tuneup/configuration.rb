module Fiveruns::Tuneup
  
  class Configuration
    
    def environments
      @environments ||= %w(development)
    end
    
    def instrument?
      environments.map(&:to_s).include?(RAILS_ENV)
    end
    
  end
  
end 