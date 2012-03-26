$:.unshift(File.dirname(__FILE__))

# gems
require 'rubygems'
require 'nokogiri'

# external
require 'uri'
require 'net/http'
require 'net/https'
require 'time'

# internal
require 'request'
require 'string'

module Messie

  # Public: encapsulates a crawled page
  #
  class Page

    # Public: create a new object and crawl the page
    #
    # uri - a String or URI object
    # block - a Block that sets headers for the request
    #
    # Examples:
    #   page = Messie::Page.crawl("http://localhost")
    #
    # Returns: a new Messie::Page object
    def self.crawl(uri, &block)
      request = Messie::Request.new(uri)

      if block_given?
        request.instance_eval(&block)
      end

      self.from_request(request)
    end

    # Public: create a Messie::Page by crawling the given Messie::Request
    #
    # request - a Messie::Request object that used to do the request to get the Messie::Page
    #
    # Examples:
    #   request = Messie::Request.new('http://localhost')
    #   page = Messie::Page.from_request(request)
    #
    # Returns: a new Messie::Page object
    def self.from_request(request)
      page = request.crawl.to_h
      page[:uri] ||= uri

      obj = self.new(page)
      obj
    end

    attr_reader :uri, :response_time, :request_headers
    attr_writer :body

    # Internal: sets a few standard headers, that can be overwritten
    #
    # data - a Hash containing the following keys:
    #        :uri - a URI or String object
    #        :body - a String
    #        :code - the response code as a Fixnum
    #        :response_time - the response time in seconds as a Float
    #        :response_headers - a Hash containing all response headers
    #        :request_headers - a Hash containing all request headers
    def initialize(data = {})
      if data[:uri].instance_of? String
        @uri = URI.parse(data[:uri])
      else
        @uri = data[:uri]
      end

      @body = data[:body]
      @code = data[:code]
      @response_time = data[:time]
      @response_headers = data[:response_headers]
      @request_headers = data[:request_headers]
    end

    # Public: returns plain text of the page (all HTML tags stripped)
    #
    # Returns: a String
    def text
      return nil if @body.nil?

      doc = nokogiri
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      text = doc.xpath('//text()').inner_text
      text.encode_to_utf8.strip
    end

    # Public: gets the response body (HTML, binary or whatever the requested resource is)
    #
    # Returns: a String
    def body
      return nil if @body.nil?

      @body.to_s.strip
    end

    # Public: get all hyperlinks on the page
    #
    # Returns: an Array containing all hyperlinks of the page
    def links
      return [] if body.nil?

      find_links.delete_if do |x|
        x =~ /^mailto\:/
      end
    end

    # Public: get the <title> of the page
    #
    # Returns: a String
    def title
      nokogiri.xpath('//title').inner_html
    end

    # Public: get a nokogiri object of the page's body
    #
    # Returns: a Nokogiri::HTML::Document representation of the page
    def nokogiri
      Nokogiri::HTML(body)
    end

    # Public: gets the response code
    #
    # Returns: a valid HTTP status code as a Fixnum
    def response_code
      @code
    end

    # Public: gets the last modified timestamp if given in the response
    #
    # Returns: a Time object
    def last_modified
      return nil unless self[:last_modified]
      Time.parse(self[:last_modified])
    end

    # Public: gets the ETag if set in the response
    #
    # Returns: a String or nil
    def etag
      self[:etag]
    end

    # Public: is the page cached on the server?
    #
    # Returns: either TrueClass or FalseClass
    def cached?
      last_modified || etag
    end

    # Public: was the page modified since the last request to it?
    #         => HTTP Status 304 Not Modified?
    #
    # Returns: either TrueClass or FalseClass
    def changed?
      return nil if @code.nil?
      @code != 304
    end

    # Public: returns the HTTP response headers
    #
    # Returns: a Hash containing the response headers like they appeared in
    #          the HTTP response (User-Agent)
    def response_headers
      headers = {}
      @response_headers.each do |key,value|
        key = key.to_s.split('_').map {|x| x.capitalize }.join('-')
        headers[key] = value
      end

      headers
    end

    private

    # Internal: get all links from the page
    #
    # Returns: an Array of links
    def find_links
      nokogiri.xpath('//a').select { |link| link['href'] }.map { |link| link['href'] }
    end

    # Internal: reads headers with an Array-like syntax
    #
    # Returns: a String
    def [](header_key)
      return nil if @response_headers.nil?
      return nil unless @response_headers.has_key? header_key

      @response_headers[header_key]
    end
  end
end
