require 'hawkular/trace'

module Hawkular

  class APMSpanContext

    attr_reader :span_id, :trace_id, :praent_id, :transaction, :consumer_correlation_id, :trace

    attr_writer :consumer_correlation_id, :trace

    def initialize(span_id, trace_id, parent_id, transaction, level)
      @span_id = span_id
      @trace_id= trace_id
      @parent_id = parent_id
      @transaction = transaction
      @level = level
      @consumer_correlation_id = nil

      @trace = Hawkular::Trace.new
    end
  end

end
