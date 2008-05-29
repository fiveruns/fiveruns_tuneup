module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def add_asset_tags_to(response)
        return unless show_for?(response)
        before, after = response.body.split(/<\/head>/i, 2)
        if after
          insertion = %(
          <!-- START FIVERUNS TUNEUP ASSETS -->
          <link rel='stylesheet' type='text/css' href='/stylesheets/tuneup/tuneup.css'/>
          #{insert_prototype unless response.body.include?('prototype.js')}
          <script type='text/javascript'>
            var TuneUp = {};
            TuneUp.frontend_url = "#{Fiveruns::Tuneup.frontend_url}";
          </script>
          <script type='text/javascript' src='/javascripts/tuneup/tuneup.js'></script>
          <!-- END FIVERUNS TUNEUP ASSETS -->
          )
          response.headers["Content-Length"] += insertion.size
          response.body.replace(before << insertion << '</head>' << after)
        end
      end
      
      def show_for?(response)
        return false unless response.body
        return false unless response.headers['Status'] && response.headers['Status'].include?('200')
        true
      end
      
      def insert_prototype
        "<script type='text/javascript' src='/javascripts/tuneup/prototype.js'></script>"
      end
      
    end
    
  end
end