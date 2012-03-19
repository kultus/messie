require File.join(File.dirname(__FILE__), %w[.. .. test_messie])

class TestEncodingDeflate < Messie::TestCase
  def test_decode
    content = "foobar"

    zipper = Zlib::Deflate.new
    buffer = zipper.deflate(content, Zlib::FINISH)

    assert_equal content, Messie::Encoding::Deflate.new(buffer).decode
  end

  def test_from_server
    page = Messie::Page.crawl "http://localhost:4567/deflate"
    assert_equal "this is a deflated text", page.body
  end
end




