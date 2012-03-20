require File.join(File.dirname(__FILE__), %w[.. .. test_messie])

class TestEncodingPlain < Messie::TestCase
  def test_decode
    content = "foobar"
    assert_equal content, Messie::Encoding::Plain.new(content).decode
  end
end