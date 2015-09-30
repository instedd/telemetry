module InsteddTelemetry
  class Counter < BaseModel
    include StatUtils

    belongs_to :period

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
