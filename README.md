# Hawkular-APM OpenTracing Ruby Implementation (Port of the [JavaScript Implementation](https://github.com/hawkular/hawkular-apm-opentracing-javascript))

OpenTracing API complient Tracer for use with the Hawkular APM server.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hawkular-apm-opentracing-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hawkular-apm-opentracing-ruby

## Usage

```ruby
require 'hawkular'
require 'opentracing'

@tracer = Hawkular::APMTracer.new({
  sampler: Hawkular::AlwaysSample.new,
  recorder: Hawkular::StdLogRecorder.new
})

OpenTracing.global_tracer = @tracer

span = OpenTracing.start_span("operation_name")
span.finish()
```

## Known Issues
This project is stull under development and much of the data still needs to be confirmed. There are even pieces of the tracer that have yet to be implemented. 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/blong14/hawkular-apm-opentracing-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

