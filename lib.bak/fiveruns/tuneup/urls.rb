module Fiveruns
  module Tuneup
    module Urls
      
      def collector_url
        @collector_url ||= begin
          url = ENV['TUNEUP_COLLECTOR'] || 'https://tuneup-collector.fiveruns.com'
          url = "http://#{url}" unless url =~ /^http/
          url
        end
      end
      
      def frontend_url
        @frontend_url ||= begin
          url = ENV['TUNEUP_FRONTEND'] || 'https://tuneup.fiveruns.com'
          url = "http://#{url}" unless url =~ /^http/
          url
        end
      end
      
    end
  end
end