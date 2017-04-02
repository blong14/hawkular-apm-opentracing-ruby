module Hawkular

  class Sampler

    def is_sampled?(trace)
      raise "Not implemented!"
    end

    def never_sample(trace)
      false
    end

    def always_sample(trace)
      true
    end

  end

  class AlwaysSample < Sampler

    def is_sampled?(trace)
      always_sample(trace)
    end

  end

  class NeverSample < Sampler

    def is_sampled?(trace)
      never_sample(trace)
    end

  end

end

