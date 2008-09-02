namespace :fiveruns do
  
  namespace :tuneup do
    
    namespace :tmp do
      
      desc "Clear tempory data (runs, etc)"
      task :clear => :environment do
        rm_rf File.join(RAILS_ROOT, 'tmp', 'tuneup')
      end
      
    end
    
  end
  
end