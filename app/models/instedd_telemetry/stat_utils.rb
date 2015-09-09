module InsteddTelemetry
  module StatUtils

    def parse_key_attributes
      @key_attributes_hash ||= JSON.parse(key_attributes)
    end

  end
end
