module InsteddTelemetry
  class Setting < BaseModel
    @cache = HashWithIndifferentAccess.new

    def self.get(key)
      if @cache.has_key?(key)
        @cache[key]
      else
        setting = find_by_key(key)
        value = setting.present? ? setting.value : nil
        @cache[key] = value
        value
      end
    end

    def self.get_bool(key)
      value = self.get(key)

      if value.nil?
        value
      else
        value == "true" || value == "t" || value == "1"
      end
    end

    def self.set(key, value)
      @cache.delete(key)
      setting = find_or_initialize_by(key: key)
      setting.value = value.to_s
      setting.save
    end

    def self.set_all(setting_values)
      setting_values = setting_values.clone.with_indifferent_access

      setting_values.keys.each do |key|
        @cache.delete(key)
      end

      self.where(key: setting_values.keys).each do |s|
        s.value = setting_values.delete(s.key)
        s.save
      end

      setting_values.each do |k,v|
        Setting.create(key: k, value: v.to_s)
      end
    end

    def self.clear_cache
      @cache.clear
    end

  end
end
