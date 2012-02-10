module Messie
  module Encoding

    # plain text content
    #
    class Plain
      def initialize(content)
        @content = content.to_s
      end

      def decode
        @content
      end
    end

  end
end