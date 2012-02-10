$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. .. lib messie}))

require 'encoding/gzip'
require 'test/unit'

class TestEncodingGzip < Test::Unit::TestCase
  def test_decode
    content = "foobar"

    buffer = StringIO.new('')
    z = Zlib::GzipWriter.new(buffer)
    z.write(content)
    z.close

    assert_equal content, Messie::Encoding::Gzip.new(buffer.string).decode
  end

  def test_from_server
    page = Messie::Page.crawl "http://localhost:4567/gzip"
    assert_equal "this is a gzipped string", page.body
  end
end




