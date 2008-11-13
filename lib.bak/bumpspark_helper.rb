require 'base64'
require 'zlib'

# Note: This is a modified copy of _why's `bumpspark' library,
# discussed and collaborated on at:
#   http://redhanded.hobix.com/inspect/sparklinesForMinimalists.html
# Many thanks to the various collaborators; _why (concept), MenTaLguY (transparency), and jzp (png)
module BumpsparkHelper #:nodoc:
  
  def build_png_chunk(type,data)
      to_check = type + data
      return [data.length].pack("N") + to_check + [Zlib.crc32(to_check)].pack("N")
  end

  def build_png(image_rows)
      header = [137, 80, 78, 71, 13, 10, 26, 10].pack("C*")
      raw_data = image_rows.map { |row| [0] + row }.flatten.pack("C*")
      ihdr_data = [   image_rows.first.length,image_rows.length,
                      8,2,0,0,0].pack("NNCCCCC")
      ihdr = build_png_chunk("IHDR", ihdr_data)
    trns = build_png_chunk("tRNS", ([ 0 ]*6).pack("C6"))
    idat = build_png_chunk("IDAT", Zlib::Deflate.deflate(raw_data))
      iend = build_png_chunk("IEND", "")

      return header + ihdr + trns + idat + iend
  end
  def bumpspark(results)    
     black = [0, 0, 0]
     white, red, grey = [0xFF,0xFF,0xFF], [0xFF,0,0], [0x99,0x99,0x99]
     rows = normalize(results).inject([]) do |ary, r|
       ary << [black]*15 << [black]*15
         ary.last[r/9,4] = [(r > 50 and red or grey)]*4
         ary
     end.transpose.reverse
     return build_png(rows)
  end
  def build_data_url(type,data)
    data = Base64.encode64(data).delete("\n")
    return "data:#{type};base64,#{CGI.escape(data)}" 
  end
  
  def normalize(results)
    min, max = results.min, results.max
    width = max - min
    return [1] * results.size if width == 0
    width += (300 * 1000)
    results.map do |result|
      ((result - min) * 100 / width.to_f).to_i
    end
  end
  
end