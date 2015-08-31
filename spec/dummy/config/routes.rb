Rails.application.routes.draw do
  mount InsteddTelemetry::Engine => "/instedd_telemetry"

  root 'home#index'
end
