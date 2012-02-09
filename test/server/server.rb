# this implements a lightweight test server
# that is used for the unit tests

require 'sinatra'

get '/' do
  '<html><title>Test Page</title></html>'
end