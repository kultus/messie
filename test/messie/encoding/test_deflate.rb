$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. .. lib messie}))

require 'encoding/deflate'
require 'test/unit'

class TestEncodingDeflate < Test::Unit::TestCase
  def test_decode
    content = "foobar"

    zipper = Zlib::Deflate.new
    buffer = zipper.deflate(content, Zlib::FINISH)

    assert_equal content, Messie::Encoding::Deflate.new(buffer).decode
  end
end




