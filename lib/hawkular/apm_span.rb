
module Hawkular

  class APMSpan < OpenTracing::Span

    Reference = Struct.new(:type, :referenced_context)

    attr_accessor :tags
    attr_reader :tracer, :span_context, :operation_name, :logs

    def initialize(tracer, fields)
      fields = pre_init(fields)
      @tracer = tracer
      @operation_name = fields.operation_name
      @tags = fields.tags || {}
      @start_millis = fields.start_time || Integer(Time.now.to_f * 1000)
      @logs = []
      @finished = false
      fields.references = init_references(fields.references)
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
      return if is_finished?
      @finished = true
      @end_millis = finish_time
      span_to_report= context.trace.is_finished(self)

      if !span_to_report.nil?
        level = context.level == Hawkular::REPORTING_LEVEL_ALL ? context.level : span_to_report.context.level
        is_sampled = context_sampling(tracer.sampler, context.trace, level)

        tracer.recorder.record(span_to_report) if is_sampled
      end
    end

    def is_finished?
      @finished
    end

    def context_sampling(sampler, trace, reporting_level)
      return false if [Hawkular::REPORTING_LEVEL_NONE, Hawkular::REPORTING_LEVEL_IGNORE].include?(reporting_level)
      return true if Hawkular::REPORTING_LEVEL_ALL == reporting_level

      sampler.is_sampled?(trace)
    end

    def trace_id
      context.trace_id
    end

    def id
      context.id
    end

    def start_time
      @start_millis
    end

    def end_time
      @end_millis
    end

    def duration
      return @start_millis && @end_millis ? @end_millis - @start_millis : 0
    end

    private

    def pre_init(fields)
      if fields.child_of
        ctx = fields.child_of.is_a?(OpenTracing::Span) ? fields.child_of.context : fields.child_of
        fields.references = Reference.new(Hawkular::REFERENCE_CHILD_OF, ctx)
      end
      fields
    end

    def init_references(references)
      if !references.nil?
        references.map! do |reference|
          Reference.new(
            reference.type,
            reference.referenced_context.is_a?(OpenTracing::Span) ? reference.referenced_context.context : reference.referenced_context
          )
        end
      end

      if references.nil? || references.empty?
        return init_child_of(references)
      end

      primary_reference = find_primary_reference(references)

      #TODO: Finish this method
    end

    def find_primary_reference(references)
      extracted_context = []
      child_of = []
      follows_from = []

      references.each do |reference|
        if reference.referenced_context.consumer_correlation_id.nil?
          extracted_context << reference
        elsif reference.type == Hawkular::REFERENCE_FOLLOWS_FROM
          follows_from << reference
        elsif reference.type == Hawkular::REFERENCE_CHILD_OF
          child_of << reference
        end
      end

      if extracted_context.size == 1
        return extracted_context.first
      elsif extracted_context.size > 1
        return nil
      end

      if child_of.size == 1
        return child_of.first
      elsif child_of.size > 1
        return nil
      end

      if follows_from.size == 1
        return follows_from.first
      end

      nil
    end

  end
end