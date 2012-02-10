$:.unshift(File.dirname(__FILE__))

# internal
require 'user_agent'
require 'response'

module Messie

  # encapsulates the HTTP request
  class Request

    attr_reader :headers, :uri

    # init request and set standard parameters
    #
    def initialize uri
      @headers = {
        'User-Agent' => Messie::UserAgent.new.to_s,
        'Accept-Charset' => 'utf-8',
        'Accept' => 'text/html,application/xhtml-xml,application/xml',
        'Cache-Control' => 'max-age=0',
        'Accept-Encoding' => 'gzip,deflate'
      }

      @uri = uri
      @response = nil
      @response_time = 0
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
    def add_header key, value
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

    private

    # crawl the page and follow HTTP redirects
    #
    def crawl_and_follow limit = 5
      fail 'http redirect too deep' if limit.zero?

      start = Time.new
      req = Net::HTTP::Get.new(request_path)

      # set headers
      @headers.each do |key, value|
        req[key] = value
      end

      response = nil

      http_request = Net::HTTP.new(@uri.host, @uri.port)
      http_request.use_ssl = @uri.scheme == 'https'

      http_request.start do |http|
        response = http.request(req)
      end
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