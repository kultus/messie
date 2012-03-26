$:.unshift(File.dirname(__FILE__))

# internal
require 'encoding/plain'
require 'encoding/deflate'
require 'encoding/gzip'

module Messie

  # Public: the response of a crawling
  #
  class Response
    attr_reader :code, :body, :time, :headers, :uri

    # Public: creates Messie::Response objects from a net/http response
    #
    # uri             - a String or URI object
    # response        - a Net::HTTPResponse response object
    # response_time   - the time the response took as a Float
    # request_headers - a Hash containing the headers that were used for the request
    #
    # Returns: Messie::Response
    def self.create(uri, response, response_time, request_headers)
      headers = {}
      response.each_header do |key, value|
        headers[key.to_s.downcase.gsub('-', '_').to_sym] = value
      end

      body = self.decode(headers[:content_encoding], response.body)
      uri = URI.parse unless uri.kind_of? URI

      self.new({
        :uri  => uri,
        :time => response_time.to_f,
        :body => body,
        :code => response.code.to_i,
        :response_headers => headers,
        :request_headers => request_headers
      })
    end

    # Internal: inits a new Messie::Response object
    #           should not used, better use Messie::Response.create() instead!
    #
    def initialize(data = {})
      @uri = data[:uri]
      @code = data[:code]
      @time = data[:time]
      @body = data[:body]
      @headers = data[:response_headers]
      @request_headers = data[:request_headers]
    end

    # Public: serializes the Messie::Response to a Hash
    #
    # Returns: a Hash containing the following keys:
    #          :uri - the URI of the request
    #          :code - the HTTP status code as a Fixnum
    #          :body - the String body of the requested page
    #          :time - the response time in seconds as a Float
    #          :response_headers - a Hash of the response headers
    #          :request_headers - a Hash of the request headers
    def to_h
      {
        :uri  => @uri,
        :code => @code,
        :body => @body,
        :time => @time,
        :response_headers => @headers,
        :request_headers => @request_headers
      }
    end

    private

    # Internal: decodes the content of the page with the given algorithm
    #
    # algorithm - a Symbol or String for the used algorithm (Gzip or Deflate)
    # body - the response body as a String
    #
    # Returns: the decoded Messie::Response body as a String
    def self.decode(algorithm, body)
      decoder = self.lookup_decoder(algorithm)
      decoder = decoder.new body
      decoder.decode
    end

    # Internal: searches for the correct algorithm class to be used to decode the
    #           response body
    #
    # falls back to Messie::Encoding::Plain if the found class doesn't responds to decode()
    #
    # algorithm - a Symbol or String
    #
    # Returns: a Class used to decode the body
    def self.lookup_decoder(algorithm)
      return Messie::Encoding::Plain if algorithm.to_s.empty?

      begin
        algorithm = Messie::Encoding.const_get algorithm.capitalize.to_sym
      rescue NameError
        algorithm = Messie::Encoding::Plain
      end

      method_name = :decode
      if 1.8 == RUBY_VERSION.to_f
        method_name = method_name.to_s
      end

      unless algorithm.instance_methods.include? method_name
        algorithm = Messie::Encoding::Plain
      end

      algorithm
    end
  end
end