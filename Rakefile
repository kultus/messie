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
  url      'https://github.com/domnikl/messie'
  ignore_file  '.gitignore'
  depend_on 'nokogiri'
  depend_on 'webrick', :development => true
  depend_on 'sinatra', :development => true
}
