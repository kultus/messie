$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. .. lib messie}))
require 'encoding/plain'
require 'test/unit'

class TestEncodingPlain < Test::Unit::TestCase
  def test_decode
    content = "foobar"
    assert_equal content, Messie::Encoding::Plain.new(content).decode
  end
end