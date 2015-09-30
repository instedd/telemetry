module InsteddTelemetry
  class Timespan < BaseModel
    include StatUtils

    attr_accessible :bucket, :key_attributes, :period_id if mass_assignment?

    belongs_to :period
  end
end
