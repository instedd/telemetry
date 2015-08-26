module InsteddTelemetry::Logging

  def self.log_exception e, extra_info
    Rails.logger.error "[instedd-telemetry] #{extra_info}" if extra_info
    Rails.logger.error e.message
    Rails.logger.error "\t#{e.backtrace.join("\n\t")}"
  end

end