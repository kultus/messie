$:.unshift(File.join(File.dirname(__FILE__)))

# external
require 'zlib'

# internal
require 'plain'

module Messie
  module Encoding

    # deflated content
    #
    class Deflate < Plain
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