module InsteddTelemetry

  # If there is a base application controller, inherit from it so we can reuse
  # the same application layout; otherwise, just inherit from base controller
  if defined?(::ApplicationController)
    class ApplicationController < ::ApplicationController
    end
  else
    class ApplicationController < ActionController::Base
    end
  end

end
