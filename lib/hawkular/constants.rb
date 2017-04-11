
module Hawkular
  CARRIER_PREFIX = 'HWKAPM'
  CARRIER_CORRELATION_ID = "#{CARRIER_PREFIX}ID"
  CARRIER_TRACE_ID = "#{CARRIER_PREFIX}TRACEID"
  CARRIER_TRANSACTION = "#{CARRIER_PREFIX}TXN"
  CARRIER_LEVEL = "#{CARRIER_PREFIX}LEVEL"

  NODE_TYPE_CONSUMER = 'Consumer'
  NODE_TYPE_PRODUCER = 'Producer'
  NODE_TYPE_COMPONENT = 'Component'

  CORR_ID_SCOPE_INTERACTION = 'Interaction'
  CORR_ID_SCOPE_CAUSED_BY = 'CausedBy'

  REPORTING_LEVEL_ALL = 'All'
  REPORTING_LEVEL_NONE = 'None'
  REPORTING_LEVEL_IGNORE = 'Ignore'

  PROP_SERVICE_NAME = 'service'
  PROP_BUILD_STAMP = 'buildStamp'

  FORMAT_HTTP_HEADERS = 'http_headers'
end