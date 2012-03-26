# Public: monkey-patching String built-in class
#
class String

  # Public: encode Strings to utf8, regardless of the version of Ruby used
  #
  # Examples:
  #   "schön".encode_to_utf8
  #
  # Returns: a new String object
  def encode_to_utf8
    if 1.8 == RUBY_VERSION.to_f
      require 'iconv'
      Iconv.conv('ISO-8859-1//TRANSLIT', 'utf-8', self)
    else
      self.encode('UTF-8')
    end
  end
end