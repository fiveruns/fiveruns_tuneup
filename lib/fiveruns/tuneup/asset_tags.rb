module Fiveruns
  module Tuneup
    
    module AssetTags
      
      def add_asset_tags_to(response)
        return unless show_for?(response)
        before, after = response.body.split(/<\/head>/i, 2)
        if after
          insertion = %(
          <!-- START FIVERUNS TUNEUP ASSETS -->
          <link rel="stylesheet" type="text/css" href="/stylesheets/tuneup/tuneup.css" />
          <script type="text/javascript"> var TuneUp = { frontend_url : '#{Fiveruns::Tuneup.frontend_url}'}; </script>
          <script type="text/javascript" src="/javascripts/tuneup/init.js"></script>
          <!-- END FIVERUNS TUNEUP ASSETS -->
          )
          add_content_length(response, insertion.size)
          response.body.replace(before << insertion << '</head>' << after)
          log :error, "Inserted asset tags"
        else
          log :error, "Could not find closing </head> tag for insertion"
        end
      end
      
      def show_for?(response)
        return false unless response.body
        return true if response.headers['ETag'] && response.headers['Content-Type'].to_s.include?('html')
        return false unless response.headers['Status'] && response.headers['Status'].include?('200')
        true
      end
      
      def insert_prototype
        "<script type='text/javascript' src='/javascripts/tuneup/prototype.js'></script>"
      end
      
      # Modify the Content-Length header, regardless if String/Fixnum, and
      # keep it the same type
      def add_content_length(response, delta)
        length = response.headers["Content-Length"]
        response.headers["Content-Length"] = case length
        when Fixnum
          length + delta
        when String
          (length.to_i + delta).to_s
        else
          length # Shouldn't happen
        end
      end
      
    end
    
  end
end