$:.unshift(File.join(File.dirname(__FILE__)))

# external
require 'zlib'

# internal
require 'plain'

module Messie
  module Encoding

    # Internal: decodes gzipped content
    #
    class Gzip < Plain

      # Internal: decodes content encoded with the Gzip algorithm
      #
      # Returns: a String containing the decoded content
      def decode
        gzip_reader = Zlib::GzipReader.new(StringIO.new(@content))
        gzip_reader.read
      end
    end

  end
end