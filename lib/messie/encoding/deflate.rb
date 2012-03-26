$:.unshift(File.join(File.dirname(__FILE__)))

# external
require 'zlib'

# internal
require 'plain'

module Messie
  module Encoding

    # Internal: decodes deflated content
    #
    class Deflate < Plain

      # Internal: decodes content encoded with the DEFLATE algorithm
      #
      # Returns: the decoded String
      def decode
        stream = Zlib::Inflate.new
        buffer = stream.inflate(@content)
        stream.finish
        stream.close

        buffer
      end
    end

  end
end