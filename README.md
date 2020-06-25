# EmlToPdf

Welcome to EmlToPdf.
A small converter to convert an eml file to a pdf.
This gem uses `wkhtmltopdf`. You can get the installer from [here](http://wkhtmltopdf.org/downloads.html)

[![Build Status](https://travis-ci.org/siegy22/eml_to_pdf.svg?branch=master)](https://travis-ci.org/siegy22/eml_to_pdf)
[![Code Climate](https://codeclimate.com/github/siegy22/eml_to_pdf/badges/gpa.svg)](https://codeclimate.com/github/siegy22/eml_to_pdf)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eml_to_pdf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eml_to_pdf

## Usage

#### Basic Setup

Use the `configure` method to configure your labels

```ruby
EmlToPdf.configure do |config|
  config.timeout = 60 # Seconds, defaults to 0
  config.from_label = "From =>"
  config.to_label = "To =>"
  config.cc_label = "Cc =>"
  config.date_label = "Date =>"
  config.date_format do |date|
    date.strftime("%Y")
  end
end
```

Use the `convert` method to covert an eml to a pdf

```ruby
EmlToPdf.convert("~/Desktop/my_test_email.eml", "~/Desktop/converted_email.pdf")
```

Or you can use the executable

    $ eml_to_pdf input-path output-path

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/siegy22/eml_to_pdf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
