module InsteddTelemetry
  class TelemetryController < InsteddTelemetry::ApplicationController

    before_filter :check_settings_not_set

    def dismiss
      InsteddTelemetry::Setting.set(:dismissed, true)

      InsteddTelemetry.update_installation

      redirect_to redirect_url
    end

    def configuration
    end

    def configuration_update
      settings = {
        disable_upload: !params[:opt_in].present?,
        dismissed: true,
        installation_info_synced: false
      }

      if params[:admin_email]
        settings[:admin_email] = params[:admin_email].strip
      end

      InsteddTelemetry::Setting.set_all(settings)

      InsteddTelemetry.update_installation

      flash[:telemetry_notice] = "Thank you for helping us improve our tools!"
      redirect_to redirect_url
    end

    private

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
