module InsteddTelemetry
  class SetOccurrence < BaseModel
    include StatUtils

    belongs_to :period
  end
end
