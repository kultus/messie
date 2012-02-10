# this implements a lightweight test server
# that is used for the unit tests

require 'rubygems'
require 'sinatra'

# external
require 'zlib'

get '/' do
  '<html><title>Test Page</title></html>'
end

get '/links' do
  '<html>
    <body>
        <a name="anchor">Anchor</a>
        <a href="https://rubygems.org/gems/messie">Messie on Rubygems.org</a>
        <a href="https://github.com/domnikl/messie">Messie on github</a>
        <a href="mailto:foo@bar.com">Email</a>
    </body>
  </html>'
end

get '/cached' do
  status 304 # Not Modified
  headers \
    "Last-Modified" => "Tue, 15 Nov 1994 12:45:26 GMT",
    "ETag" => "1edec-3e3073913b100",
    "Expires" => "Fri, 10 Feb 2012 01:59:35 GMT"
  body "this was cached"
end

get '/redirect' do
  status 301 # Moved Permanently
  headers \
    "Location" => "http://localhost:4567"
  body "foo"
end

get '/gzip' do
  buffer = StringIO.new('')
  z = Zlib::GzipWriter.new(buffer)
  z.write("this is a gzipped string")
  z.close

  headers \
    "Content-Encoding" => "gzip"
  body buffer.string
end

get '/deflate' do
  zipper = Zlib::Deflate.new
  buffer = zipper.deflate("this is a deflated text", Zlib::FINISH)

  headers \
    "Content-Encoding" => "deflate"
  body buffer
end