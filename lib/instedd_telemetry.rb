Dir[File.expand_path("../instedd_telemetry/**/*.rb", __FILE__)].each do |file|
  require file
end

module InsteddTelemetry

  extend Tracking

  def self.setup(&block)
    case block.arity
    when 0
      configuration.instance_eval(&block)
    when 1
      block.call(configuration)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.instance_id
    @instance_id ||= load_instance_id
  end

  def self.upload_enabled
    not Setting.get_bool(:disable_upload)
  end

  def self.api
    @api ||= Api.new(configuration.server_url)
  end

  def self.application
    configuration.application
  end

  def self.ensure_period_exists
    self.current_period
  end

  def self.current_period
    if current_period_cached
      @current_period
    else
      @current_period = InsteddTelemetry::Period.current
    end
  end

  def self.update_installation
    unless Setting.get(:installation_data_uploaded)
      params = {application: InsteddTelemetry.application}
      admin_email = InsteddTelemetry::Setting.get(:admin_email)
      params[:admin_email] = admin_email if admin_email.present?

      begin
        InsteddTelemetry.api.update_installation(params) rescue nil
        Setting.set(:installation_data_uploaded, true)
      rescue
      end
    end
  end

  private

  def self.current_period_cached
    !Rails.env.test? && @current_period && DateTime.now < @current_period.end
  end

  def self.load_instance_id
    id_setting = InsteddTelemetry::Setting.find_or_create_by(key: :installation_id) do |guid_setting|
      guid_setting.value = SecureRandom.uuid
    end

    id_setting.value
  end

end
