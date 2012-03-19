require File.join(File.dirname(__FILE__), %w[.. test_messie])

class TestResponse < Messie::TestCase
  def test_init
    response = Messie::Response.new {}

    assert_nil(response.code)
    assert_nil(response.body)
    assert_nil(response.time)
    assert_nil(response.headers)
    assert_nil(response.uri)
  end

  def test_to_h
    data = {
      :body => 'Moved permanently',
      :uri => nil,
      :code => 302,
      :time => 0.93234,
      :response_headers => {
        :last_modified => Time.now
      },
      :request_headers => nil,
    }

    response = Messie::Response.new(data)
    assert_equal(data, response.to_h)
  end
end