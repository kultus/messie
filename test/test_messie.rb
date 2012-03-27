$:.unshift(File.join(File.dirname(__FILE__), %w{.. lib}))

require 'simplecov'
SimpleCov.start

require 'messie'
require 'test/unit'

module Messie
  class TestCase < Test::Unit::TestCase
    def test_module
      assert_not_nil Messie::VERSION
    end
  end
end