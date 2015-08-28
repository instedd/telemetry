require "instedd_telemetry/engine"
require "instedd_telemetry/agent"
require "instedd_telemetry/logging"
require "instedd_telemetry/configuration"

module InsteddTelemetry

  def self.set_add(bucket, key_attributes, element)
    swallowing_errors do
      in_transaction do
        SetOccurrence.find_or_create_by({
          bucket: bucket,
          key_attributes: serialize_key_attributes(key_attributes),
          element: element,
          period_id: UploadProcess.current_period.id
        })
      end
    end
  end

  def self.counter_add(bucket, key_attributes, amount = 1)
    swallowing_errors do
      in_transaction do
        counter = Counter.find_or_initialize_by({
          bucket: bucket,
          key_attributes: serialize_key_attributes(key_attributes),
          period_id: UploadProcess.current_period.id
        })
        counter.add amount
        counter.save
      end
    end
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  private

  def self.serialize_key_attributes attributes
    Hash[attributes.sort].to_json
  end

  #
  # Our code could be running inside a transaction in the host application.
  #
  # By default, in ActiveRecord statements in a transaction nested in the code become part
  # of the parent transaction (instead of creating a new nested database transaction).
  #
  # This may lead to unexpected behaviour regarding error handling. 'requires_new' forces
  # ActiveRecord to create a new, nested database transaction to avoid these problems.
  #
  # In database engines that don't support native nested transactions, such as MySQL and
  # PostgreSQL, these are simulated using savepoints.
  #
  # For more details see http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
  #
  def self.in_transaction(&block)
    ActiveRecord::Base.transaction(requires_new: true, &block)
  end

  def self.swallowing_errors(&block)
    begin
      yield
    rescue Exception => e
      Logging.log_exception e, "An error occurred while trying to save usage stats"
    end
  end

end
