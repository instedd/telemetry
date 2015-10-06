module InsteddTelemetry::Logging

  def self.log(level, message)
    Rails.logger.send(level, "[instedd-telemetry] #{message}")
  end

  def self.log_exception e, extra_info
    header = extra_info ? "#{extra_info}: #{e.message}" : "#{e.message}"
    log :error, "#{header}\n\t#{e.backtrace.join("\n\t")}"
  end

end