module InsteddTelemetry
  class Setting < BaseModel

    def self.get(key)
      setting = find_by_key(key)
      setting.present? ? setting.value : nil
    end

    def self.set(key, value)
      setting = find_or_initialize_by(key: key)
      setting.value = value
      setting.save
    end

  end
end