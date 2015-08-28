module InsteddTelemetry
  class Counter < BaseModel

    belongs_to :period

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
