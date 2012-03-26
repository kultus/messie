module Messie
  module Encoding

    # Internal: plain text content
    #
    class Plain

      # Internal: inits the plain text encoding
      #
      # content - a String containing the encoded string
      def initialize(content)
        @content = content.to_s
      end

      # Internal: decode the String
      #
      # Returns: the decoded String
      def decode
        @content
      end
    end

  end
end