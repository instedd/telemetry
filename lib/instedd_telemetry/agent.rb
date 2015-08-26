class InsteddTelemetry::Agent
  def initialize
  end

  def auto_start
    start if should_start?
  end

  def start
    Thread.new { InsteddTelemetry::UploadProcess.start_upload_process }
  end

  def should_start?
    !blacklisted_constants && !blacklisted_executables
  end

  private

  def blacklisted_constants
    ['Rails::Console'].any?{|x| is_constant_defined? x}
  end

  def blacklisted_executables
    ['irb', 'rspec', 'rake'].any?{|x| x == File.basename($0)}
  end

  def is_constant_defined?(name)
    !name.constantize.nil? rescue false
  end

end
