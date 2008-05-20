module Fiveruns
  module Tuneup
    module Runs
      
      def run_dir
        @run_dir ||= File.join(RAILS_ROOT, 'tmp', 'fiveruns_tuneup', 'runs')
      end
      
      def last_run
        filename = run_files.last
        load_from_file(filename) if filename
      end
      
      def load_from_file(filename)
        decompressed = Zlib::Inflate.inflate(File.open(filename, 'rb') { |f| f.read })        
        YAML.load(decompressed)
      end
      
      def run_files
        Dir[File.join(run_dir, '*.yml.gz')]
      end
      
      #######
      private
      #######
      
      def persist(environment, data)
        FileUtils.mkdir_p run_dir
        compressed = Zlib::Deflate.deflate(package_for(environment, data).to_yaml)
        File.open(File.join(run_dir, "#{now}.yml.gz"), 'wb') { |f| f.write compressed }
      end
      
      def package_for(environment, data)
        {'environment' => environment, 'stack' => data}
      end
      
      def now
        Time.now.to_f
      end
      
    end
    
  end

end