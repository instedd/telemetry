module InsteddTelemetry
  class TelemetryController < InsteddTelemetry::ApplicationController

    before_filter :check_settings_not_set

    def dismiss
      InsteddTelemetry::Setting.set(:dismissed, true)
      redirect_to redirect_url
    end

    def configuration
    end

    def configuration_update
      settings = {
        disable_upload: !params[:telemetry_enabled].present?,
        dismissed: true
      }

      if params[:admin_email]
        admin_email = params[:admin_email].strip
        settings[:admin_email] = admin_email
        InsteddTelemetry.api.update_installation(admin_email: admin_email)
      end

      InsteddTelemetry::Setting.set_all(settings)

      flash[:telemetry_notice] = "Thank you for helping us improve our tools!"
      redirect_to redirect_url
    end

    def check_settings_not_set
      if InsteddTelemetry::Setting.where(key: :disable_upload).any?
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def redirect_url
      params[:redirect_url] || "/"
    end

  end
end
