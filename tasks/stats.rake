namespace :fiveruns do
  
  namespace :tuneup do
    
    namespace :stats do
      
      desc "Generate trend statistics"
      task :trend => :environment do 
      
        begin
          require "ruport"
          require "ruport/util"
          require "ruport/util/graph"
          require "scruffy"
        rescue LoadError
          abort "Required the 'ruport', 'ruport-util', and 'scruffy' gems"
        end
        
        output_dir = File.join(RAILS_ROOT, 'tmp', 'tuneup', 'stats', 'trend', Rails.env, Time.now.to_i.to_s)
        index = Fiveruns::Tuneup::Stats::Trend.new(output_dir).save
        
        begin
          require 'launchy'
          Launchy::Browser.run(index)          
        rescue LoadError
          if RUBY_PLATFORM['darwin']
            system('open', index) 
          else
            puts "Generated #{index}"
          end
        end
      
      end
      
      
    end
    
  end
  
end

