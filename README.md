messie
===========

Messie is a simple web crawler that crawls one page at a time.

Features
--------

* follows HTTP redirects (max 5 levels deep)
* get all links a page contains to continue crawling recursively
* supports caching of pages
* decompression of gzip or deflate compressed is completely handled by messie
* return plain text from web pages
* crawl SSL encrypted pages
* set your own request headers via a fancy API
* directly access the page's content with Nokogiri
* records the response time of every crawled page
* contains a CLI tool that uses the complete API

Examples
--------

```ruby
page = Messie::Page.crawl "http://www.google.de" do
    # these respond to method_missing, so any header key
    # might be allowed here

    accept_charset 'utf-8'
    accept 'text/html'
end

page.response_code # => 200
page.response_time # => 0.83234
page.body          # => "<html><title>foo</title>... <h1>Foobar</h1>"
page.text          # => "Foobar ..."
page.title         # => foo
page.links         # => ['http://www.google.com', 'http://www.foobar.com']
page.nokogiri      # => <Nokogiri::Document>
```

Caching
=======

When it comes to caching pages, messie takes a lot of work from you. All you have to do is to persist
`page.last_modified` and `page.etag` and provide them on your next call to `Messie::Page.crawl`.

```ruby
page = Messie::Page.crawl "http://www.google.de" do
  if_modified_since Time.now
  if_none_match "1edec-3e3073913b101"
end

page.changed? # => false
page.cached? # => true, the resource is being cached by the server
page.etag # => "1edec-3e3073913b101"
page.last_modified # => #<Time>
```

Requirements
------------

* sanitize
* nokogiri

Install
-------

* `[sudo] gem install messie`

Author
------

Original author: Dominik Liebler <liebler.dominik@googlemail.com>

License
-------

(The MIT License)

Copyright (c) 2012 Dominik Liebler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
