InsteddTelemetry::Engine.routes.draw do
  match 'dismiss', to: 'telemetry#dismiss', as: :dismiss, via: [:get, :post]
  match 'configure', to: 'telemetry#configure', as: :configure, via: [:get, :post]
end
