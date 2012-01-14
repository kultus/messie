$:.unshift(File.join(File.dirname(__FILE__), %w{.. .. lib messie}))
require 'user_agent'
require 'test/unit'

class TestUserAgent < Test::Unit::TestCase
  def setup
    @user_agent = Messie::UserAgent.new
  end

  def test_to_s
    assert_match(/Messie Crawler v[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$/, @user_agent.to_s)
    assert_no_match(/0\.0\.0/, @user_agent.to_s)
  end

  def test_version
    assert_match(/[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$/, @user_agent.version)
  end
end
