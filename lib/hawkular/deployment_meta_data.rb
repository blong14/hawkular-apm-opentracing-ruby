
module Hawkular

  class DeploymentMetaData

    attr_reader :service_name, :build_stamp

    def initialize(service_name, build_stamp = nil)
      @service_name = service_name
      @build_stamp = build_stamp
    end
  end

end
