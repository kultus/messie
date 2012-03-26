module Messie

  # Public: User agent for the crawler
  #
  # Examples:
  #   Messie::UserAgent.new.to_s # => "Messie Crawler v1.0.0"
  class UserAgent

    # Public: returns the standard user agent identification
    #
    # Returns: a String
    def to_s
      "Messie Crawler v#{Messie::VERSION}"
    end
  end
end