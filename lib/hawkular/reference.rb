
module Hawkular

  class Reference

    attr_reader :type

    def initialize(type, referenced_context)
      @type = type
      @referenced_context = referenced_context
    end

    def referenced_context
      @referenced_context || Hawkular::APMSpanContext.new({})
    end

    def reference_context=(ctx)
      @referenced_context = ctx
    end

    def type=(type)
      @type = type
    end

  end

end
