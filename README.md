# Ngzip

This gem allows easy integration of nginx mod_zip into your ruby/rails application by providing
the formatted output list and a HTTP header to use the on-thy-fly creation of ZIP archives.

## Installation

Add this line to your application's Gemfile:

    gem 'ngzip'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ngzip

## Usage

In a controller

```ruby
b = Nginx::Builder.new()
response.headers['X-Archive-Files'] = 'zip'
render :text => b.build("/data/test/Report.pdf", "/data/test/LargeArchive.tar")
```

### nginx configuration

Compile nginx with the mod_zip module from https://github.com/evanmiller/mod_zip.

Configure nginx to serve files with absolute paths from an internal location

    # mod_zip location helper
  	# Note: The leading ^~ is essential here, no more checks should be done after this match
  	location ^~ /data/ {
    	root /;
    	internal;
  	}

Note that we only operate with local files in this examples. The module mod_zip uses subrequests to 
fetch the actual file data and would support any location type (even proxied).

## License

Copyright (c) 2013, ncode gmbh. All Rights Reserved.

This project is licenced under the [MIT License](LICENSE.txt).

