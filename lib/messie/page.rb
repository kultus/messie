$:.unshift(File.dirname(__FILE__))

# gems
require 'rubygems'
require 'sanitize'
require 'nokogiri'

# external
require 'uri'
require 'net/http'

# internal
require 'user_agent'

module Messie
  class Page
    # create a new object and crawl the page
    #
    def self.crawl uri, &block
      obj = self.new uri

      if block_given?
        obj.instance_eval(&block)
      end

      obj.crawl
      obj
    end

    attr_reader :uri, :response_time, :headers

    # sets a few standard headers, that can be overwritten
    #
    def initialize uri
      @uri = URI.parse(uri)
      @response = nil
      @body = nil

      @headers = {
        'User-Agent' => Messie::UserAgent.new.to_s,
        'Accept-Charset' => 'utf-8',
        'Accept' => 'text/html,application/xhtml-xml,application/xml',
        'Cache-Control' => 'max-age=0'
      }
    end

    # get the response of the crawling
    # 
    def crawl
      if @response.nil?
        @response = crawl_and_follow
      end

      self
    end

    # return plain text of the page
    #
    #
    def text
      doc = Nokogiri::HTML(body)
      doc.xpath('//script').remove
      doc.xpath('//style').remove
      
      text = doc.to_html.encode('UTF-8')

      Sanitize.clean(text)
    end

    # get the response body
    # 
    def body
      if not @body.nil?
        @body
      elsif @response.nil?
        nil
      else
        @response.body.strip
      end
    end

    # setter for body
    #
    def body=(body)
      @body = body
    end

    # get the title of the page
    #
    def title
      return nil if body.nil?

      doc = Nokogiri::HTML(body)
      doc.xpath('//title').inner_html
    end

    # get the response code
    #
    # :call-seq:
    #
    def response_code
      return nil if @response.nil?
      @response.code.to_i
    end

    # set a HTTP request header
    #
    def add_header key, value
      @headers[key] =value
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

    def request_path
      if @uri.path.length == 0
        '/'
      else
        @uri.path
      end
    end

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

      @response_time = stop - start

      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPRedirection
        @uri = URI.parse(response['location'])
        crawl_and_follow(limit - 1)
      else
        response.error!
      end
    end
  end
end