module InsteddTelemetry::StatCollectors
  module Utils
    def simple_counter(metric, key, value)
      {
        counters: [
          {
            metric: metric,
            key: key,
            value: value
          }
        ]
      }
    end
  end
end
