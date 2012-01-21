module Messie

  # a crawled response
  class Response
    attr_reader :code, :body, :time

    #
    def initialize(data={})
      @code = data[:code]
      @time = data[:time]
      @body = data[:body]
    end

    # convert to a hash
    def to_h
      {:code => @code, :body => @body, :time => @time}
    end
  end
end