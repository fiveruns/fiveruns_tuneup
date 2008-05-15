module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def add_asset_tags_to(body)
        body.sub!(/<\/head>/i, %(
        <!-- START FIVERUNS TUNEUP ASSETS -->
        <link rel='stylesheet' media='screen' href='/tuneup/asset?file=tuneup.css' type='text/css'/>
        <script type='text/javascript' src='/tuneup/asset?file=prototype.js'></script>
        <script type='text/javascript' src='/tuneup/asset?file=tuneup.js'></script>
        <!-- END FIVERUNS TUNEUP ASSETS -->       
        </head>))
      end
      
    end
    
  end
end