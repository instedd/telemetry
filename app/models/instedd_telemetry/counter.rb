module InsteddTelemetry
  class Counter < BaseTracker

    belongs_to :period

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
