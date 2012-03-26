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
  class Page
    # create a new object and crawl the page
    #
    def self.crawl uri, &block
      request = Messie::Request.new uri

      if block_given?
        request.instance_eval(&block)
      end

      self.from_request(request)
    end

    # Public: create a Messie::Page by crawling the given Messie::Request
    def self.from_request(request)
      page = request.crawl.to_h
      page[:uri] ||= uri

      obj = self.new(page)
      obj
    end

    attr_reader :uri, :response_time
    attr_writer :body

    # sets a few standard headers, that can be overwritten
    #
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

    # return plain text of the page
    #
    #
    def text
      return nil if @body.nil?

      doc = nokogiri
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      text = doc.xpath('//text()').inner_text
      text.encode_to_utf8.strip
    end

    # get the response body
    # 
    def body
      return nil if @body.nil?

      @body.to_s.strip
    end

    # get all hyperlinks on the page
    #
    def links
      return [] if body.nil?

      find_links.delete_if do |x|
        x =~ /^mailto\:/
      end
    end

    # get the title of the page
    #
    def title
      nokogiri.xpath('//title').inner_html
    end

    # get a nokogiri object of the page's body
    #
    def nokogiri
      Nokogiri::HTML(body)
    end

    # get the response code
    #
    # :call-seq:
    #
    def response_code
      @code
    end

    # last modified timestamp
    def last_modified
      return nil unless self[:last_modified]
      Time.parse(self[:last_modified])
    end

    # Entity Tag
    def etag
      self[:etag]
    end

    # is the page cached on the server?
    def cached?
      last_modified || etag
    end

    # was the page modified since the last request to it?
    # => HTTP Status 304 Not Modified?
    def changed?
      return nil if @code.nil?
      @code != 304
    end

    def response_headers
      headers = {}
      @response_headers.each do |key,value|
        key = key.to_s.split('_').map {|x| x.capitalize }.join('-')
        headers[key] = value
      end

      headers
    end

    def request_headers
      @request_headers
    end

    protected

    # get ALL links from the body section of the page
    #
    def find_links
      links = []
      nokogiri.xpath('//a').each do |link|
        links << link['href'] if link['href']
      end

      links
    end

    # read headers
    def [](header_key)
      return nil if @response_headers.nil?
      return nil unless @response_headers.has_key? header_key

      @response_headers[header_key]
    end
  end
end
