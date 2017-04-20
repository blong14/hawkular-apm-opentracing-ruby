require 'test_helper'

class Hawkular::APMSpanTest < Minitest::Test

  def setup
    @recorder = MiniTest::Mock.new
    @tracer = Hawkular::APMTracer.new({
      sampler: Hawkular::AlwaysSample.new,
      recorder: @recorder
    })
  end

  def test_finish
    span = @tracer.start_span('finish')
    @recorder.expect(:record, nil, [span])

    span.finish

    assert_operator span.start_time, :<=, span.end_time
    assert_operator span.end_time, :<=, Integer(Time.now.to_f * 1000)
  end

  def test_should_record_on_finish
    span = @tracer.start_span('my_span')
    @recorder.expect(:record, nil, [span])

    span.finish

    assert @recorder.verify
  end

  def test_duration
    start_time = Integer(Time.now.to_f * 1000)
    span = @tracer.start_span('duration_span', {start_time: start_time})
    @recorder.expect(:record, nil, [span])

    sleep 0.5
    span.finish

    assert_operator 0, :<, span.duration
    assert_operator span.start_time, :<, span.end_time
    assert_equal span.end_time - span.start_time, span.duration
  end

  def test_log_with_timestamp
    span = @tracer.start_span('operation')

    assert_empty span.logs

    span.log({size: 15}, 2)

    refute_empty span.logs
    assert_equal span.logs, [{key: 'size', value: 15, timestamp: 2}]
  end

  def test_log_without_timestamp
    span = @tracer.start_span('operation')

    assert_empty span.logs

    span.log({size: 15, prop: 'str'})

    logs = span.logs

    sleep 0.5

    refute_empty logs
    assert_equal 2, logs.size

    assert_equal logs[0][:key], 'size'
    assert_equal logs[0][:value], 15
    assert_operator Integer(Time.now.to_f * 1000), :>, logs[0][:timestamp]

    assert_equal logs[1][:key], 'prop'
    assert_equal logs[1][:value], 'str'
    assert_operator Integer(Time.now.to_f * 1000), :>, logs[1][:timestamp]
  end

  def test_set_tag
    span = @tracer.start_span('tag')
    assert_empty span.tags

    span.set_tag('key', 'value')
    span.set_tag('key2', 'value2')

    assert_equal span.tags, {key: 'value', key2: 'value2'}
  end

  def test_add_tag
    span = @tracer.start_span('add_tag', tags: {key0: 'value0'})

    span.add_tags({
      key1: 'value1',
      key2: 'value2',
      key3: 'value3'
    })

    assert_equal span.tags, {key0: 'value0', key1: 'value1', key2: 'value2', key3: 'value3'}
  end

end
