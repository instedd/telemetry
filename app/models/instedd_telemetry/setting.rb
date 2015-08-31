module InsteddTelemetry
  class Setting < BaseModel

    def self.get(key)
      setting = find_by_key(key)
      setting.present? ? setting.value : nil
    end

    def self.get_bool(key)
      value = self.get(key)
      
      if value.nil?
        value
      else
        value == "true"
      end
    end

    def self.set(key, value)
      setting = find_or_initialize_by(key: key)
      setting.value = value.to_s
      setting.save
    end

  end
end