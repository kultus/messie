# this implements a lightweight test server
# that is used for the unit tests

require 'rubygems'


require 'webrick'
require 'webrick/https'
require 'openssl'
require 'optparse'

cert_path = File.join(File.dirname(__FILE__), 'crt')

private_key = File.read(File.join(cert_path, 'server.key'))
certificate = File.read(File.join(cert_path, 'server.crt'))

options = {
    :port => 4567,
    :use_ssl => false,
}

optparse = OptionParser.new('Usage: server.rb [options]') do |opts|
  opts.on('-p PORT', '--port PORT', 'set port to use') do |port|
    options[:port] = port.to_i
  end

  opts.on('-s', '--use-ssl', 'use ssl?') do
    options[:use_ssl] = true
  end
end

optparse.parse!

require 'sinatra'

webrick_options = {
  :Port               => options[:port],
  :DocumentRoot       => ".",
  :SSLEnable          => options[:use_ssl],
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(certificate),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(private_key),
  :SSLCertName        => [["localhost", 'localhost']]
}



# external
require 'zlib'

class TestServer < Sinatra::Base
  get '/' do
    '<html><title>Test Page</title></html>'
  end

  get '/links' do
    '<html>
      <body>
          <div>
            <a name="anchor">Anchor</a>
            <a href="https://rubygems.org/gems/messie">Messie on Rubygems.org</a>
            <a href="https://github.com/domnikl/messie">Messie on github</a>
            <a href="mailto:foo@bar.com">Email</a>
          </div>
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

  get '/ssl-test' do
    body "Foobar"
  end
end

puts "starting WEBrick with SSL set to #{options[:use_ssl]} on port #{options[:port]}"

Rack::Handler::WEBrick.run TestServer, webrick_options
