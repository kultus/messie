$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. lib messie}))
require 'response'
require 'test/unit'

class TestResponse < Test::Unit::TestCase
  def test_init
    response = Messie::Response.new {}

    assert_nil(response.code)
    assert_nil(response.body)
    assert_nil(response.time)
    assert_nil(response.headers)
  end

  def test_to_h
    data = {
      :body => 'Moved permanently',
      :code => 302,
      :time => 0.93234,
      :headers => {
        :last_modified => Time.now
      }
    }

    response = Messie::Response.new(data)
    assert_equal(data, response.to_h)
  end
end