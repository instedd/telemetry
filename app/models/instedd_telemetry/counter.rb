module InsteddTelemetry
  class Counter < BaseModel
    include StatUtils

    attr_accessible :bucket, :key_attributes, :period_id if mass_assignment?

    belongs_to :period

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
