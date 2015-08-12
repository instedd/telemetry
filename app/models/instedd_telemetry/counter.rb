module InsteddTelemetry
  class Counter < Model

    def add(amount)
      self.count ||= 0
      self.count += amount
    end

  end
end
