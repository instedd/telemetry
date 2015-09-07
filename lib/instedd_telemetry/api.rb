class InsteddTelemetry::Api
  def initialize(base_uri)
    @base_uri = URI(base_uri)
  end

  def create_event(event)
    req = Net::HTTP::Post.new("/api/v1/installations/#{InsteddTelemetry.instance_id}/events", {'Content-Type' =>'application/json'})
    req.body = event.to_json

    perform(req)
  end

  def update_installation(installation_params)
    req = Net::HTTP::Put.new("/api/v1/installations/#{InsteddTelemetry.instance_id}", {'Content-Type' =>'application/json'})
    req.body = installation_params.to_json

    perform(req)
  end

  protected

  def perform(request)
    Net::HTTP.new(@base_uri.hostname, @base_uri.port).request(request)
  end
end
