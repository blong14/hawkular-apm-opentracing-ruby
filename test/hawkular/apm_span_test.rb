require 'test_helper'

class Hawkular::APMSpanTest < Minitest::Test

  def setup
    @recorder = MiniTest::Mock.new
    @tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::AlwaysSample.new,
      recorder: @recorder
    })
  end

  def test_should_record_on_finish
    span = @tracer.start_span('my_span')
    @recorder.expect(:record, span)

    span.finish

    assert @recorder.verify
  end

end
