$:.unshift(File.join(File.dirname(__FILE__)))

# external
require 'zlib'

# internal
require 'plain'

module Messie
  module Encoding

    # gzipped content
    #
    class Gzip < Plain
      def decode
        gzip_reader = Zlib::GzipReader.new(StringIO.new(@content))
        gzip_reader.read
      end
    end

  end
end