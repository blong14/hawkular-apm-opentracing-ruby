require 'opentracing'
require 'hawkular/basic_utils'

module Hawkular

  class APMTracer < OpenTracing::Tracer
    include Hawkular::BasicUtils

    attr_reader :sampler, :recorder, :trace_decorator

    def self._inject_http_and_text_map(span_context, carrier)
      carrier[Hawkular::CARRIER_TRACE_ID] = span_context.trace_id
      carrier[Hawkular::CARRIER_CORRELATION_ID] = generate_span_id
      carrier[Hawkular::CARRIER_TRANSACTION] = span_context.transaction if span_context.transaction
      carrier[Hawkular::CARRIER_LEVEL] = span_context.level if span_context.level > 0
    end

    def self._extract_http_and_text_map(carrier)
      correlation_id = nil
      trace_id = nil
      transaction = nil
      level = nil
      carrier.keys.each do |key|
        case key.upcase
        when Hawkular::CARRIER_CORRELATION_ID
          correlation_id = carrier[key]
        when Hawkular::CARRIER_TRACE_ID
          trace_id = carrier[key]
        when Hawkular::CARRIER_TRANSACTION
          transaction = carrier[key]
        when Hawkular::CARRIER_LEVEL
          level = carrier[key]
        else
        end
      end

      span_context = Hawkular::APMSpanContext.new({
        span_id: generate_span_id,
        trace_id: trace_id,
        parent_id: nil,
        transaction: transaction,
        level: level
      })
      span_context.consumer_correlation_id = correlation_id

      span_context
    end

    def initialize(options = {})
      @recorder = options[:recorder] || Hawkular::StdLogRecorder.new
      @sampler = options[:sampler] || Hawkular::AlwaysSample.new

      # TODO: Figure out what to do with this below line
      deployment_meta_data = options[:deployment_meta_data] || Hawkular::DeploymentMetaData.new('hawkular-service')

      @trace_decorator = Proc.new do |trace|
        root_node = trace.nodes[0]
        if root_node
          span = root_node.span
          if span
            if deployment_meta_data.service_name && !span.tags.keys.include?(Hawkular::PROP_SERVICE_NAME)
              span.set_tag(Hawkular::PROP_SERVICE_NAME, deployment_meta_data.service_name)
            end

            if deployment_meta_data.build_stamp && !span.tags.keys.include?(Hawkular::PROP_BUILD_STAMP)
              span.set_tag(Hawkular::PROP_BUILD_STAMP, deployment_meta_data.build_stamp);
            end
          end
        end
      end
    end

    def start_span(name, fields = {})
      fields_with_operation = fields
      fields_with_operation[:operation_name] = name
      Hawkular::APMSpan.new(self, fields_with_operation)
    end

    def inject(span_context, format, carrier)
      return if carrier.nil?

      span_context = span_context.context if span_context.is_a?(Hawkular::APMSpan)

      if format.eql?(Hawkular::FORMAT_HTTP_HEADERS) || format.eql?(Hawkular::FORMAT_TEXT_MAP)
        APMTracer._inject_http_and_text_map(span_context, carrier)
      end

      span_context.trace.set_node_type(Hawkular::NODE_TYPE_PRODUCER, span_context, {
        value: carrier[Hawkular::CARRIER_CORRELATION_ID.to_sym],
        scope: Hawkular::CORR_ID_SCOPE_INTERACTION
      })
    end

    def extract(format, carrier)
      if format.eql?(Hawkular::FORMAT_HTTP_HEADERS) || format.eql?(OpenTracing::FORMAT_TEXT_MAP)
        span_context = APMTracer._extract_http_and_text_map(carrier)
      else
        span_context = Hawkular::APMSpanContext.new({})
      end

      span_context
    end

  end

end
