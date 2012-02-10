$:.unshift(File.dirname(__FILE__))

require 'encoding/plain'
require 'encoding/deflate'
require 'encoding/gzip'

module Messie

  # a crawling response
  #
  class Response
    attr_reader :code, :body, :time, :headers, :uri

    # factory method to create from net/http response
    def self.create(uri, response, response_time)
      headers = {}
      response.each_header do |key, value|
        headers[key.to_s.downcase.gsub('-', '_').to_sym] = value
      end

      body = self.decode(headers[:content_encoding], response.body)

      self.new({
        :uri  => uri,
        :time => response_time.to_f,
        :body => body,
        :code => response.code.to_i,
        :headers => headers
      })
    end

    def initialize(data={})
      @uri = data[:uri]
      @code = data[:code]
      @time = data[:time]
      @body = data[:body]
      @headers = data[:headers]
    end

    # convert to a hash
    def to_h
      {
        :uri  => @uri,
        :code => @code,
        :body => @body,
        :time => @time,
        :headers => @headers
      }
    end

    private

    # gzipped content
    #
    def self.decode(algorithm, body)
      decoder = self.lookup_decoder(algorithm)
      decoder = decoder.new body
      decoder.decode
    end

    # search for the correct algorithm class
    #
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