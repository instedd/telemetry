module InsteddTelemetry
  class Timespan < BaseModel
    include StatUtils

    belongs_to :period
  end
end
