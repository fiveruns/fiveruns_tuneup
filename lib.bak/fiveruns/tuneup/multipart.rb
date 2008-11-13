require 'net/http'
require 'cgi'

module Fiveruns

  module Tuneup

    class Multipart
    
      BOUNDARY_ROOT = 'B0UND~F0R~UPL0AD'
    
      attr_reader :file, :params
      def initialize(file, params={})
        @file = file
        @params = params
      end
    
      def content_type
        %(multipart/form-data, boundary="#{boundary}")
      end
    
      def to_s
        %(#{parts}\r\n#{separator}--)
      end
      
      #######
      private
      #######
      
      def boundary
        "#{BOUNDARY_ROOT}*#{nonce}"
      end
      
      def parts
        params.merge(:file => file).map do |name, value|
          [
            separator,
            headers_for(name, value)
          ].flatten.join(crlf) + crlf + crlf + content_of(value)
        end.flatten.join(crlf)
      end
      
      def separator
        %(--#{boundary})
      end
      
      def crlf
        @crlf ||= "\r\n"
      end
      
      def headers_for(name, value)
        if value.respond_to?(:read)
          [
            %(Content-Disposition: form-data; name="#{name}"; filename="#{File.basename(value.path)}"),
            %(Content-Transfer-Encoding: binary),
            %(Content-Type: application/octet-stream)
          ]
        else
          [ %(Content-Disposition: form-data; name="#{name}") ]
        end
      end
      
      def nonce
        @nonce ||= (Time.now.utc.to_f * 1000).to_i
      end
      
      def content_of(value)
        value.respond_to?(:read) ? value.read : value.to_s
      end
    
    end  
  
  end
  
end
