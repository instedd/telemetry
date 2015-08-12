module InsteddTelemetry
  class Counter < StatModel

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
