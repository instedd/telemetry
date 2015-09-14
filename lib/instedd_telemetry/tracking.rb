module InsteddTelemetry::Tracking

  def set_add(bucket, key_attributes, element)
    safely do
      SetOccurrence.find_or_create_by({
        bucket: bucket,
        key_attributes: serialize_key_attributes(key_attributes),
        element: element,
        period_id: InsteddTelemetry.current_period.id
      })
    end
  end

  def counter_add(bucket, key_attributes, amount = 1)
    safely do
      counter = Counter.find_or_initialize_by({
        bucket: bucket,
        key_attributes: serialize_key_attributes(key_attributes),
        period_id: InsteddTelemetry.current_period.id
      })
      counter.add amount
      counter.save
    end
  end

  def timespan_update(bucket, key_attributes, since, untill = Time.now)
    safely do
      timespan = Timespan.find_or_initialize_by({
        bucket: bucket,
        key_attributes: serialize_key_attributes(key_attributes),
        period_id: InsteddTelemetry.current_period.id
      })
      timespan.since = since if timespan.new_record?
      timespan.until = untill
      timespan.save
    end
  end

  def timespan_since_creation_update(bucket, key_attributes, record)
    timespan_update(bucket, key_attributes, record.created_at)
  end

  def user_lifespan_update(user)
    timespan_since_creation_update(:user_lifespan, {user_id: user.id}, user)
  end

  private

  def serialize_key_attributes attributes
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
  def safely
    begin
      ActiveRecord::Base.transaction(requires_new: true) do
        yield
      end
    rescue Exception => e
      Logging.log_exception e, "An error occurred while trying to save usage stats"
    end
  end

end