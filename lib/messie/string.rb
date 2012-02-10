# monkey-patching String built-in class
#
class String
  def encode_to_utf8
    if 1.8 == RUBY_VERSION.to_f
      require 'iconv'
      Iconv.conv('ISO-8859-1//TRANSLIT', 'utf-8', self)
    else
      self.encode('UTF-8')
    end
  end
end