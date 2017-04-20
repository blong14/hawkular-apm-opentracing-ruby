require 'test_helper'
require 'opentracing'

class Hawkular::APMTracerTest < Minitest::Test

  def setup
    @recorder = Minitest::Mock.new
    @tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::AlwaysSample.new,
      recorder: @recorder
    })
  end

  def test_should_create_100_spans
    100.times do
      span = @tracer.start_span('my_span')
      @recorder.expect(:record, nil, [span])

      span.finish
    end
  end

end
