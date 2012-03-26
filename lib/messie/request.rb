$:.unshift(File.dirname(__FILE__))

# internal
require 'user_agent'
require 'response'
require 'openssl'
require 'uri'

module Messie

  # encapsulates the HTTP request
  class Request

    attr_reader :headers, :uri

    # init request and set standard parameters
    #
    # uri - a String or URI object to be crawled
    #
    # Returns: a new Messie::Request object
    def initialize uri
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
    end

    # Public: sets the URI to be requested
    #
    # uri - a String or URI
    def uri=(uri)
      uri = URI.parse(uri) unless uri.kind_of? URI
      @uri = uri
    end

    # get the response of the crawling
    #
    def crawl
      if @response.nil?
        @response = crawl_and_follow
      end

      @response
    end

    # set a HTTP request header
    #
    def add_header(key, value)
      @headers[key] = value
    end

    # method missing to respond to setting of headers
    # with dynamic methods
    #
    def method_missing(m, *args, &block)
      key = m.to_s.split('_').map {|x| x.capitalize }.join('-')
      value = args.shift

      add_header(key, value)
    end

    # sets the cert store to use if requesting HTTPS resources
    # @param store OpenSSL::X509::Store
    def ssl_cert_store store
      @ssl_cert_store = store
    end

    # set the SSL verify mode, either OpenSSL::SSL::VERIFY_PEER or OpenSSL::SSL::VERIFY_NONE
    # @param mode
    def ssl_verify_mode mode
      @ssl_verify_mode = mode
    end

    private

    # crawl the page and follow HTTP redirects
    #
    def crawl_and_follow limit = 5
      fail 'http redirect too deep' if limit.zero?

      start = Time.new
      get_request = Net::HTTP::Get.new(request_path)

      # set headers
      @headers.each do |key, value|
        get_request[key] = value
      end

      request = Net::HTTP.new(@uri.host, @uri.port)

      if @uri.scheme == 'https'
        request.use_ssl = true
        request.verify_mode = @ssl_verify_mode
        request.cert_store = @ssl_cert_store
      end

      response = request.request(get_request)
      stop = Time.new

      @response_time += stop - start

      case response
      when Net::HTTPSuccess
        Messie::Response.create(@uri, response, @response_time, @headers)
      when Net::HTTPNotModified
        Messie::Response.create(@uri, response, @response_time, @headers)
      when Net::HTTPRedirection
        @uri = URI.parse(response['location'])
        crawl_and_follow(limit - 1)
      else
        response.error!
      end
    end

    # get the request path
    def request_path
      if @uri.path.length == 0
        '/'
      else
        @uri.path
      end
    end

  end
end