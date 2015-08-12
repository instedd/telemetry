module InsteddTelemetry
  class SetOccurrence < Model
    
    def key_attributes
      @key_attributes_hash ||= JSON.parse(super)
    end

  end
end