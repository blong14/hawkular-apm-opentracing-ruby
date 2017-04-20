
module Hawkular

  class Reference

    attr_accessor :type, :referenced_context

    def initialize(type, referenced_context)
      @type = type
      @referenced_context = referenced_context
    end

  end

end
