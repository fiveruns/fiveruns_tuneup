module Fiveruns
  module Tuneup
    module Runs
      
      def run_dir
        @run_dir ||= File.join(RAILS_ROOT, 'tmp', 'tuneup', 'runs', RAILS_ENV)
      end
      
      def retrieve_run(run_id)
        filename = filename_for(run_id)
        if File.file?(filename)
          load_from_file(filename)
        else
          log :error, "Couldn't find filename: #{filename}"
          nil
        end
      end
      
      def load_from_file(filename)
        decompressed = Zlib::Inflate.inflate(File.open(filename, 'rb') { |f| f.read })        
        YAML.load(decompressed)
      end
      
      def last_filename_for_run_uri(uri)
        filename_for(last_run_id_for(uri))
      end
      
      def last_run
        last_file = sorted_run_files.last
        load_from_file(last_file)
      end
      
      #######
      private
      #######
      
      def sorted_run_files
        Dir[File.join(run_dir, '*/*.gz')].sort_by do |f|
          File.basename(f).split('_').first.to_i
        end
      end
            
      def trend_for(run_id)
        Dir[File.join(run_dir, File.dirname(run_id), "*.gz")].map do |filename|
          Integer(File.basename(filename, '.yml.gz').split('_').last)
        end
      end
      
      def last_run_id_for(url)
        last_file = Dir[File.join(run_dir, stub(url), '*.gz')].last
        if last_file
          File.join(File.basename(File.dirname(last_file)), File.basename(last_file, '.yml.gz'))
        end
      end
      
      # Use Run ID, current timestamp, and total time (in microseconds)
      def generate_run_id(url, time)
        timestamp = '%d' % (Time.now.to_f * 1000)
        File.join(stub(url), timestamp.to_s << "_#{(time * 1000).to_i}")
      end
      
      def persist(run_id, environment, schemas, data)
        log :info, "Persisting #{run_id}"
        filename = filename_for(run_id)
        FileUtils.mkdir_p File.dirname(filename)
        compressed = Zlib::Deflate.deflate(package_for(run_id, environment, schemas, data).to_yaml)
        File.open(filename, 'wb') { |f| f.write compressed }
      end
      
      def filename_for(run_id)
        File.join(run_dir, run_id) << '.yml.gz'
      end
      
      def stub(url)
        Digest::SHA1.hexdigest(url)
      end
      
      def package_for(run_id, environment, schemas, data)
        {'id' => run_id, 'environment' => environment, 'schemas' => schemas, 'stack' => data}
      end
      
    end
    
  end

end