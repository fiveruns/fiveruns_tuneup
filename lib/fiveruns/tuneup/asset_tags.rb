module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def style_asset
        @style_asset ||= read_asset('tuneup.css')
      end
      
      def js_asset
        @js_asset ||= read_asset('tuneup.js')
      end
      
      def add_asset_tags_to(response)
        return unless response.body
        before, after = response.body.split(/<\/head>/i, 2)
        if after
          insertion = %(
          <!-- START FIVERUNS TUNEUP ASSETS -->
          <style type='text/css'>#{style_asset}</style>
          #{insert_prototype unless response.body.include?('prototype.js')}
          <script type='text/javascript'>//<!--\n#{js_asset}\n// --></script>
          <!-- END FIVERUNS TUNEUP ASSETS -->
          )
          response.headers["Content-Length"] += insertion.size
          response.body.replace(before << insertion << '</head>' << after)
        end
      end
      
      def read_asset(filename)
        File.read(File.dirname(__FILE__) << "/../../../assets/#{filename}").strip
      end
      
      def insert_prototype
        "<script type='text/javascript' src='/tuneup/asset?file=prototype.js'></script>"
      end
      
    end
    
  end
end