module InsteddTelemetry
  class SetOccurrence < StatModel
    
    def key_attributes
      @key_attributes_hash ||= JSON.parse(super)
    end

  end
end