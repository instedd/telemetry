InsteddTelemetry::Engine.routes.draw do

  match 'dismiss', to: 'telemetry#dismiss', as: :dismiss, via: [:get, :post]
  
  get  'configure'  => 'telemetry#configuration'
  post 'configure'  => 'telemetry#configuration_update'

end
