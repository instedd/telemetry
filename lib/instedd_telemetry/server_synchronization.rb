module InsteddTelemetry
  module ServerSynchronization
    class << self

      def start
        while true
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              InsteddTelemetry.update_installation

              if !InsteddTelemetry.upload_enabled
                Logging.log :info, "User opted-out of telemetry report uploads, will not upload usage information."
              else
                run_once
              end
            rescue Exception => e
              Logging.log_exception e, "An error occurred while trying to upload usage stats"
            end
          end
          sleep InsteddTelemetry.configuration.process_run_interval
        end
      end

      def run_once
        InsteddTelemetry.ensure_periods_exists

        custom_collectors = InsteddTelemetry.configuration.collectors

        InsteddTelemetry::Period.lock_for_upload do |periods|
          if periods.any?
            periods.each do |p|
              InsteddTelemetry::PeriodUpload.new(p, custom_collectors).run
              InsteddTelemetry::Logging.log :info, "Uploaded information for period #{p.beginning}-#{p.end}"
            end
          else
            InsteddTelemetry::Logging.log :info, "There is no new information to upload"
          end
        end
      end

    end
  end
end
