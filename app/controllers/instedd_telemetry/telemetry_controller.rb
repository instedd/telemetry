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

      settings = {
        disable_upload: !params[:telemetry_enabled].present?,
        dismissed: true
      }
      
      if params[:admin_email]
        settings[:admin_email] = params[:admin_email].strip
      end
      
      InsteddTelemetry::Setting.set_all(settings)


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

