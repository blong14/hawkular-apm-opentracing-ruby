
module Hawkular

  class Reference

    attr_accessor :type, :referenced_context

    def initialize(type, referenced_context)
      @type = type
      @referenced_context = referenced_context
    end

    def referenced_context
      @referenced_context || Hawkular::APMSpanContext.new({})
    end

  end

end
