module InsteddTelemetry
  class SetOccurrence < BaseModel
    include StatUtils

    attr_accessible :bucket, :key_attributes, :element, :period_id if mass_assignment?

    belongs_to :period
  end
end
