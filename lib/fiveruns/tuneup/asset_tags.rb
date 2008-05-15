module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def add_asset_tags_to(body)
        return body unless body
        body.sub!(/<\/head>/i, %(
        <!-- START FIVERUNS TUNEUP ASSETS -->
        <link rel='stylesheet' media='screen' href='/tuneup/asset?file=tuneup.css' type='text/css'/>
        #{insert_prototype unless body.include?('prototype.js')}
        <script type='text/javascript' src='/tuneup/asset?file=tuneup.js'></script>
        <!-- END FIVERUNS TUNEUP ASSETS -->       
        </head>))
      end
      
      def insert_prototype
        "<script type='text/javascript' src='/tuneup/asset?file=prototype.js'></script>"
      end
      
    end
    
  end
end