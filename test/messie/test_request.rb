require File.join(File.dirname(__FILE__), %w[.. test_messie])
require 'net/http'

class TestRequest < Messie::TestCase
  def setup
    @request = Messie::Request.new "http://localhost:4567"
  end

  def test_inject_http_request
    uri = URI.parse("http://localhost:4567/")
    net_request = Net::HTTP.new(uri.host, uri.port)

    request = Messie::Request.new(uri, net_request)
    page = Messie::Page.from_request(request)
    assert_equal 'Test Page', page.title

    # second crawl request, reusing the Net::HTTP object
    request2 = Messie::Request.new("http://localhost:4567/deflate", net_request)
    page2 = Messie::Page.from_request(request2)
    assert_equal "this is a deflated text", page2.body
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

  def test_ssl
    # this is just a basic test that runs against the local server!
    store = OpenSSL::X509::Store.new
    store.add_file File.join(File.dirname(__FILE__), %w[.. server crt server.crt])

    page = Messie::Page.crawl "https://localhost:4568/ssl-test" do
      ssl_verify_mode OpenSSL::SSL::VERIFY_PEER
      ssl_cert_store store
    end

    assert_equal 200, page.response_code
    assert_equal 'Foobar', page.body
  end
end