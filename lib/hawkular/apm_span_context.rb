require 'hawkular/trace'

module Hawkular

  class APMSpanContext < OpenTracing::SpanContext

    attr_reader :span_id, :trace_id, :parent_id, :transaction, :consumer_correlation_id, :trace, :level

    attr_writer :consumer_correlation_id, :trace, :level

    def initialize(baggage)
      @span_id = baggage[:span_id]
      @trace_id= baggage[:trace_id]
      @parent_id = baggage[:parent_id]
      @transaction = baggage[:transaction]
      @level = baggage[:level]
      @consumer_correlation_id = nil

      @trace = Hawkular::Trace.new
      @baggage = baggage
    end
  end

end
