module Fiveruns::Tuneup
  
  module Stats
    
    class Trend
      
      attr_reader :output_directory
      
      def initialize(output_directory)
        @output_directory = output_directory
      end
      
      def save
        prepare_directories!
        pages = write_pages!
        write_index_to pages
      end
      
      def write_index_to(pages)
        index = File.join(output_directory, 'index.html')
        File.open(index, 'w') do |f|
          f.puts template(:index).result(binding)
        end
        index
      end
        
      def image_directory
        @image_directory ||= File.join(output_directory, 'images')
      end
      
      def prepare_directories!
        FileUtils.mkdir_p image_directory
      end
            
      def sets
        @sets ||= Dir[File.join(RAILS_ROOT, 'tmp', 'tuneup', 'runs', Rails.env, '*')].inject({}) do |all, dir|
          uri_id = File.basename(dir)
          all[uri_id] = []
          Dir[File.join(dir, '*.yml.gz')].each do |file|
            run_id = File.basename(file, '.yml.gz')
            full_run_id = File.join(File.basename(dir), run_id)
            run = Fiveruns::Tuneup.retrieve_run(full_run_id)
            raw_date, raw_value = run_id.split('_')
            date = Time.at(Integer(raw_date) / 1000)
            all[uri_id] << [date, run['stack'], run['stack'].size, Integer(raw_value) / 1000.0]
          end
          all
        end
      end
      
      def write_pages!
        sets.inject({}) do |pages, (uri_id, data)|  
          next pages unless data.size > 1
          name = name_of(data.first[1])
          next pages unless name
          images = {'Response Time (ms)' => data.map(&:last), 'Number of Steps' => data.map { |p| p[2] }}.map do |title, points|
            underscored = title.gsub(/\s+/, '_').underscore
            graph = Ruport::Data::Graph((1..data.size).to_a.map(&:to_s))
            graph.series points, title
            file = "#{uri_id}-#{underscored}.svg"
            graph.save_as(File.join(image_directory, file), :min_value => 0, :width => 800)
            file
          end
          File.open(File.join(output_directory, "#{uri_id}.html"), 'w') do |f|
            f.puts template(:page).result(binding)
          end
          pages[name] = uri_id
          pages
        end
      end

      def name_of(step)
        if step.respond_to?(:name) && step.name =~ /Perform (\S+) action in (\S+)/
          "#{$2}##{$1.underscore}"
        else
          step.children.each do |child|
            result = name_of(child)
            return result if result
          end
          nil
        end
      end
      
      def template(name)
        filename = File.join(File.dirname(__FILE__), "../../../tasks/templates", "#{name}.erb")
        ERB.new(File.read(filename))
      end
      
    end
    
  end
  
end