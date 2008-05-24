namespace :fiveruns do
  
  namespace :tuneup do
    
    namespace :tmp do
      
      desc "Clear tempory data (runs, etc)"
      task :clear => :environment do
        rm_rf File.join(RAILS_ROOT, 'tmp', 'tuneup')
      end
      
    end
    
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