require 'httparty'

module Hawkular

  class StdLogRecorder

    attr_reader :traces

    def initialize
      @traces = []
    end

    def record(span)
      return if span.nil?

      trace = {
        traceId: span.trace_id,
        parentId: span.parent_id,
        spanId: span.id,

        operationName: span.operation_name,
        startTime: span.start_time,
        duration: span.duration,
        logs: span.logs,
        tags: span.tags
      }

      @traces << trace
      puts trace.inspect
    end

    def clear
      @traces = []
    end

  end

  class HttpRecorder
    include HTTParty

    attr_reader :log_recorder, :endpoint, :timeout

    private :log_recorder, :endpoint, :timeout

    def initialize(url, username, password, debug = false, timeout = 0)
      self.class.base_uri url
      self.class.basic_auth(username, password)

      @endpoint = '/hawkular/apm/traces/fragments'
      @timeout = timeout
      @log_recorder = StdLogRecorder.new if debug
    end

    def record(span)
      return if span.nil?

      trace = span
                .context
                .trace
                .from_span(span)

      log_recorder.record(span) unless log_recorder.nil?

      self.class.post(endpoint, body: [trace].to_json, timeout: timeout, headers: headers)
    end

    private

    def headers
      {
        'Content-Type'.to_sym => 'application/json'
      }
    end

  end

end
