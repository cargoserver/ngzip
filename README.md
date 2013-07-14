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

    b = Nginx::Builder.new()
    response.headers['X-Archive-Files'] = 'zip'
    render :text => b.build("/data/test/Report.pdf", "/data/test/LargeArchive.tar")

## TODO


## License

Copyright (c) 2013, ncode gmbh. All Rights Reserved.

This project is licenced under the [MIT License](LICENSE.txt).

