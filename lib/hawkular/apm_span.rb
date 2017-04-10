
module Hawkular

  class APMSpan < OpenTracing::Span

    attr_accessor :tags
    attr_reader :tracer, :span_context, :operation_name

    def initialize(tracer, fields)
      pre_init(fields)
      @tracer = tracer
      @operation_name = fields.operation_name
      @tags = fields.tags || {}
      @start_millis = fields.start_time || Integer(Time.now.to_f * 1000)
      @logs = []
      @finished = false
      @span_context.trace.trace_decorator = tracer.trace_decorator
    end

    def context
      span_context
    end

    def operation_name=(operation_name)
      @operation_name = operation_name
      self
    end

    def log(key_value_pairs, time = Time.now)
      key_value_pairs.each do |key, value|
        logs << {
          key: key,
          value: value,
          timestamp: time
        }
      end
    end

    def set_tag(key, value)
      if !key.nil? && !value.nil?
        tags[key] = value
        if Hawkular::SamplingPriority.eql?(key)
          span_context.level = value.to_i > 0 ? Hawkular::REPORTING_LEVEL_ALL : Hawkular::REPORTING_LEVEL_NONE
        end
      end
      self
    end

    def add_tags(key_value_pairs)
      key_value_pairs.each do |key, value|
        set_tag(key, value)
      end
      self
    end

    def finish(finish_time = Time.now)

    end

    private

    def pre_init(fields)

    end

  end
end