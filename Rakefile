require 'rubygems'

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'messie'
  authors  'Dominik Liebler'
  email    'liebler.dominik@googlemail.com'
  url      'http://thewebdev.'
  ignore_file  '.gitignore'
  depend_on 'sanitize'
  depend_on 'nokogiri'
}
