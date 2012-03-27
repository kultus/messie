require 'rubygems'

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

namespace :test do
  namespace :server do
    desc "start test servers for Messie"
    task :start do
      system '(ruby test/server/server.rb --port 4567 &);'
      system '(ruby test/server/server.rb --use-ssl --port 4568 &);'
    end

    desc "stop test servers for Messie"
    task :stop do
      system "ps ax | grep test/server/server.rb | grep -v grep | awk '{print $1}' | xargs kill -9"
    end

    desc "restart test servers"
    task :restart => [:stop, :start]
  end
end

Bones {
  name     'messie'
  authors  'Dominik Liebler'
  email    'liebler.dominik@googlemail.com'
  url      'https://github.com/domnikl/messie'
  ignore_file  '.gitignore'
  depend_on 'nokogiri'
  depend_on 'webrick', :development => true
  depend_on 'sinatra', :development => true
  depend_on 'simplecov', :development => true
}
