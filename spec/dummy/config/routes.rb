Rails.application.routes.draw do
  mount InsteddTelemetry::Engine => "/instedd_telemetry"

  root to: 'home#index'
end
