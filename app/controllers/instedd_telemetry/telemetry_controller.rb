module InsteddTelemetry
  class TelemetryController < InsteddTelemetry::ApplicationController

    before_filter :check_settings_not_set

    def dismiss
      # TO-DO
    end

    def configuration
    end

    def configuration_update
      url = params[:redirect_url] || "/"

      disable_upload = !params[:telemetry_enabled].present?

      InsteddTelemetry::Setting.set(:disable_upload, disable_upload)
      InsteddTelemetry::Setting.set(:admin_email, params[:admin_email].strip) if params[:admin_email]
      InsteddTelemetry::Setting.set(:dismissed, true)

      flash[:telemetry_notice] = "Thank you for helping us improve our tools!"
      redirect_to(url)
    end

    def check_settings_not_set
      if InsteddTelemetry::Setting.where(key: :disable_upload).any?
        raise ActionController::RoutingError.new('Not Found')
      end
    end

  end
end

