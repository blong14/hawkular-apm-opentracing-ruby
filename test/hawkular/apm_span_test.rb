require 'test_helper'

class Hawkular::APMSpanTest < Minitest::Test

  def setup
    @recorder = Hawkular::StdLogRecorder.new
    @tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::AlwaysSample.new,
      recorder: @recorder
    })
  end

  def test_should_record_on_finish
    recorder = MiniTest::Mock.new
    tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::AlwaysSample.new,
      recorder: recorder
    })
    span = tracer.start_span('my_span')
    recorder.expect(:record, nil, [span])

    span.finish

    assert recorder.verify
  end

  def test_duration
    start_time = Integer(Time.now.to_f * 1000)
    span = @tracer.start_span('duration_span', {start_time: start_time})

    sleep 0.5
    span.finish

    assert_operator 0, :<, span.duration
    assert_operator span.start_time, :<, span.end_time
    assert_equal span.end_time - span.start_time, span.duration
  end

end
