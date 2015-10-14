if defined?(::PhusionPassenger)
  ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
    InsteddTelemetry::Agent.instance.start
  end
end
