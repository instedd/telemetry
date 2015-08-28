module InsteddTelemetry::Logging

  def self.log(level, message)
    Rails.logger.send(level, "[instedd-telemetry] #{message}")
  end

  def self.log_exception e, extra_info
    log :error, "[instedd-telemetry] #{extra_info}" if extra_info
    log :error, e.message
    log :error, "\t#{e.backtrace.join("\n\t")}"
  end

end