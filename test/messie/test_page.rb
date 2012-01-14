$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. lib messie}))
require 'page'
require 'test/unit'

class TestPage < Test::Unit::TestCase
  def setup
    @page = Messie::Page.crawl "http://www.google.de"
  end

  def test_init
    page = Messie::Page.new "http://www.google.de"

    assert_instance_of(URI::HTTP, page.uri)
    assert_nil(page.response_time)
    assert_nil(page.body)
    assert_nil(page.text)
    assert_nil(page.response_code)
  end

  def test_response_code
    assert_equal 200, @page.response_code
  end

  def test_response_time
    assert @page.response_time < 2
  end

  def test_body
    assert_not_nil(@page.body)
    assert_match(/<html>/, @page.body)
  end

  def test_text
    assert_not_equal(@page.text, @page.body)
    assert_no_match(/\<[a-z0-9\ \=\"\-]\>/i, @page.text)

    assert_no_match(/function/, @page.text)
  end
end