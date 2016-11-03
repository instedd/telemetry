module InsteddTelemetry::ControllerMethods
  def redirect_to_telemetry_config_unless_dismissed
    unless InsteddTelemetry::Setting.get_bool(:dismissed) || self.kind_of?(InsteddTelemetry::TelemetryController)
      redirect_to instedd_telemetry.configure_path
    end
  end
end
