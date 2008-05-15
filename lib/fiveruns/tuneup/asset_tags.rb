module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def add_asset_tags_to(body)
        body.sub!(/<\/head>/i, %(
          <!-- START FIVERUNS TUNEUP ASSETS -->
          <link rel='stylesheet' media='screen' href='/stylesheets/fiveruns-tuneup.css' type='text/css'/>
          <script type='text/javascript' src='/javascripts/prototype.js'></script>
          <script type='text/javascript' src='/javascripts/fiveruns-tuneup.js'></script>
          <!-- END FIVERUNS TUNEUP ASSETS -->          
        </head>))
      end
      
    end
    
  end
end