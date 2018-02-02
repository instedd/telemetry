module InsteddTelemetry
  module ApplicationHelper

    # These methods delegate path and url helpers to main_app, a proxy of the
    # main application routes, if they fail to be found. This works around
    # the fact that Devise URL helpers, which are used by GUISSO, do not
    # use main_app for evaluating route helpers, as noted here:
    # https://github.com/plataformatec/devise/wiki/How-To:-Use-devise-inside-a-mountable-engine#path-helpers

    # The following code was taken from:
    # http://candland.net/2012/04/17/rails-routes-used-in-an-isolated-engine/

    def method_missing method, *args, &block
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          main_app.send(method, *args)
        else
          super
        end
      else
        super
      end
    end

    def respond_to?(method, include_all = false)
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          true
        else
          super
        end
      else
        super
      end
    end

  end
end
