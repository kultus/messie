$:.unshift(File.dirname(__FILE__))

# internal
require 'user_agent'
require 'response'

# external
require 'openssl'
require 'uri'

module Messie

  # Public: encapsulates the HTTP request
  #
  # Examples:
  #   request = Messie::Request.new("http://localhost")
  #   request.add_header('foo', 'bar')
  #   request.user_agent('foobar_user_agent_1.0')
  #   response = request.crawl
  class Request
    attr_reader :headers, :uri

    # Public: inits the request and sets standard parameters
    #
    # uri - a String or URI object to be crawled
    # request - an optional Net::HTTPRequest object
    def initialize(uri, request = nil)
      @headers = {
        'User-Agent' => Messie::UserAgent.new.to_s,
        'Accept-Charset' => 'utf-8',
        'Accept' => 'text/html,application/xhtml-xml,application/xml',
        'Cache-Control' => 'max-age=0',
        'Accept-Encoding' => 'gzip,deflate'
      }

      self.uri = uri
      @response = nil
      @response_time = 0
      @ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER

      request ||= Net::HTTP.new(@uri.host, @uri.port)
      @request = request
    end

    # Public: sets the URI to be requested
    #
    # uri - a String or URI
    def uri=(uri)
      uri = URI.parse(uri) unless uri.kind_of? URI
      @uri = uri
    end

    # Public: crawl the page and get the Messie::Response object
    #
    # force_reload - True or False that allows for requesting a
    #                fresh instance of the Messie::Response object
    #
    # Returns: a Messie::Response object
    def crawl(force_reload = false)
      if @response.nil? or force_reload
        @response = crawl_and_follow
      end

      @response
    end

    # Public: set a HTTP request header
    #
    # key - a valid HTTP String header name
    # value - String value for the key
    #
    # Returns: a String describing the set value
    def add_header(key, value)
      @headers[key] = value
    end

    # Internal: method missing to respond to setting of headers
    # with dynamic methods
    #
    # method - a String method name
    # args - an Array of arguments supplied
    # block - a Block supplied to the called method
    #
    # Returns: a String describing the set value
    def method_missing(method, *args, &block)
      key = method.to_s.split('_').map {|x| x.capitalize }.join('-')
      value = args.shift

      add_header(key, value)
    end

    # Public: sets the cert store to use if requesting HTTPS resources
    #
    # store - an OpenSSL::X509::Store object
    #
    # Returns: the set OpenSSL::X509::Store object
    def ssl_cert_store(store)
      @ssl_cert_store = store
    end

    # Public: sets the SSL verify mode, either OpenSSL::SSL::VERIFY_PEER or OpenSSL::SSL::VERIFY_NONE
    #
    # mode - the set Fixnum SSL mode
    #
    # Returns: Fixnum the set SSL mode
    def ssl_verify_mode(mode)
      @ssl_verify_mode = mode
    end

    private

    # Internal: crawls the page and follows HTTP redirects (if any)
    #
    # limit - a Fixnum counting the max HTTP redirects
    #
    # Returns: a Messie::Response object
    def crawl_and_follow(limit = 5)
      fail 'HTTP redirect too deep' if limit.zero?

      get_request = Net::HTTP::Get.new(request_path)

      # set headers
      @headers.each do |key, value|
        get_request[key] = value
      end

      if @uri.scheme == 'https'
        @request.use_ssl = true
        @request.verify_mode = @ssl_verify_mode
        @request.cert_store = @ssl_cert_store
      end

      start = Time.new
      response = @request.request(get_request)

      @response_time += Time.new - start

      case response
      when Net::HTTPSuccess
        Messie::Response.create(@uri, response, @response_time, @headers)
      when Net::HTTPNotModified
        Messie::Response.create(@uri, response, @response_time, @headers)
      when Net::HTTPRedirection
        new_uri = URI.parse(response['location'])
	
	if @uri.host != new_uri.host or @uri.port != new_uri.port
	  @request = Net::HTTP.new(new_uri.host, new_uri.port)
	end
	
	@uri = new_uri
	
        crawl_and_follow(limit - 1)
      else
        response.error!
      end
    end

    # Internal: returns the request path (e.g. /foo/bar for http://localhost/foo/bar)
    #
    # Returns: a String describing the request path
    def request_path
      return '/' if @uri.path.length == 0
      @uri.path
    end
  end
end