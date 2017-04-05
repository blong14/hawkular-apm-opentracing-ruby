require 'test_helper'

class Hawkular::SamplerTest < Minitest::Test

  def test_never_sample
    recorder = Hawkular::StdLogRecorder.new
    tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::NeverSample.new,
      recorder: recorder
    })

    span = tracer.start_span('foo')
    span.finish

    assert_equals(recorder.traces.count, 0)
  end

  def test_never_ample_extracted_context_all_level
    recorder = Hawkular::StdLogRecorder.new
    tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::NeverSample.new,
      recorder: recorder
    })

    extracted_context = tracer.extract(Hawkular::FORMAT_TEXT_MAP, setup_carrier(Hawkular::REPORTING_LEVEL_ALL))

    span = tracer.start_span('foo', {child_of: extracted_context})
    span.finish

    assert_equals(recorder.tracers.count, 1)
  end

  def setup_carrier(level)
    {
      Hawkular::CARRIER_TRACE_ID => 'foo',
      Hawkular::CARRIER_CORRELATION_ID => 'foo',
      Hawkular::CARRIER_LEVEL => level
    }
  end

end
