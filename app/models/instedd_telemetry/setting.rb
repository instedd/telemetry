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

    def self.set_all(setting_values)
      setting_values = setting_values.clone.with_indifferent_access
      
      self.where(key: setting_values.keys).each do |s|
        s.value = setting_values.delete(s.key)
        s.save
      end

      setting_values.each do |k,v|
        Setting.create(key: k, value: v.to_s)
      end

    end

  end
end