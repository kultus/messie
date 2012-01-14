module Messie
  # User agent for the crawler
  #
  class UserAgent
    # user agent identification
    #
    def to_s
      "Messie Crawler v#{version}"
    end

    # get the version from version.txt
    #
    def version
      begin
        File.read(version_file).strip
      rescue Errno::ENOENT # => file does not exist
        '0.0.0'
      end
    end

    private

    def version_file
      File.join(File.dirname(__FILE__), %w{.. .. version.txt})
    end
  end
end