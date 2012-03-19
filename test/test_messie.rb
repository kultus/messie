$:.unshift(File.join(File.dirname(__FILE__), %w{.. lib}))
require 'messie'
require 'test/unit'

module Messie
  class TestCase < Test::Unit::TestCase
  end
end