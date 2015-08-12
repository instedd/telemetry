require "instedd_telemetry/engine"

module InsteddTelemetry

  def self.set_add(bucket, key_attributes, element)
    swallowing_errors do
      in_transaction do
        SetOccurrence.find_or_create_by({
          bucket: bucket,
          key_attributes: serialize_key_attributes(key_attributes),
          element: element
        })
      end
    end
  end

  def self.counter_add(bucket, key_attributes, amount = 1)
    swallowing_errors do
      in_transaction do
        counter = Counter.find_or_initialize_by({
          bucket: bucket,
          key_attributes: serialize_key_attributes(key_attributes)
        })
        counter.add amount
        counter.save
      end
    end
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
    rescue
      Rails.logger.warn "[instedd-telemetry] An error occurred while trying to save usage stats"
    end
  end

end
