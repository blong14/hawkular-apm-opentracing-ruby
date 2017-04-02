
module Hawkular

  class StdLogRecorder

    attr_reader :traces

    def initialize
      @traces = []
    end

    def record(span)
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
      base_uri url
      basic_auth(username, password)
      @endpoint = '/hawkular/apm/traces/fragments'
      @timeout = timeout
      @log_recorded = StdLogRecorder.new if debug
    end

    def record(span)
      return unless span.present?

      trace = span
                .context
                .get_trace
                .from_span(span)

      log_recorder.record(span) if log_recorder.present?

      post(endpoint, body: [trace].to_json, timeout: timeout, headers: headers)
    end

    private

    def headers
      {
        'Content-Type': 'application/json',
      }
    end

  end

end
