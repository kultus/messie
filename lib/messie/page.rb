$:.unshift(File.dirname(__FILE__))

# gems
require 'rubygems'
require 'sanitize'
require 'nokogiri'

# external
require 'uri'
require 'net/http'

# internal
require 'request'

module Messie
  class Page
    # create a new object and crawl the page
    #
    def self.crawl uri, &block
      request = Messie::Request.new URI.parse(uri)

      if block_given?
        request.instance_eval(&block)
      end

      response = request.crawl

      page = response.to_h.merge({:uri => URI.parse(uri)})

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
    end

    # return plain text of the page
    #
    #
    def text
      return nil if @body.nil?

      doc = Nokogiri::HTML(@body)
      doc.xpath('//script').remove
      doc.xpath('//style').remove
      
      text = doc.to_html.encode('UTF-8')

      Sanitize.clean(text)
    end

    # get the response body
    # 
    def body
      return nil if @body.nil?

      @body.to_s.strip
    end

    # get the title of the page
    #
    def title
      doc = Nokogiri::HTML(body)
      doc.xpath('//title').inner_html
    end

    # get the response code
    #
    # :call-seq:
    #
    def response_code
      @code
    end
  end
end