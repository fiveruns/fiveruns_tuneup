namespace :fiveruns do
  
  namespace :tuneup do
    
    namespace :assets do
          
      desc "Install assets"
      task :install => :environment do
        require File.dirname(__FILE__) << "/../install"        
      end
    
      desc "Uninstall assets"
      task :uninstall => :environment do
        require File.dirname(__FILE__) << "/../uninstall"
      end  
      
      task :reset => [:uninstall, :install]
      
    end
    
  end
  
end