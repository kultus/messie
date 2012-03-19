require File.join(File.dirname(__FILE__), %w[.. test_messie])

class TestRequest < Messie::TestCase
  def setup
    @request = Messie::Request.new "http://localhost:4567"
  end

  def test_headers
    @request.add_header('Accept-Charset', 'iso-8859-1')
    assert_equal('iso-8859-1', @request.headers['Accept-Charset'])
  end

  def test_headers_method_missing
    @request.accept_charset('utf-8')
    assert_equal('utf-8', @request.headers['Accept-Charset'])
  end

  def test_complete_crawl_stack
    page = Messie::Page.crawl "http://localhost:4567" do
      accept_charset 'utf-8'
    end

    assert_not_equal('', page.body)
  end

  def test_redirect
    page = Messie::Page.crawl "http://localhost:4567/redirect"

    assert_equal 'http://localhost:4567', page.uri.to_s
    assert_equal 200, page.response_code
    assert_equal 'Test Page', page.title
  end
end