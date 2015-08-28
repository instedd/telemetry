module InsteddTelemetry
  class SetOccurrence < BaseModel

    belongs_to :period
    
    def key_attributes
      @key_attributes_hash ||= JSON.parse(super)
    end

  end
end