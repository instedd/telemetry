require "instedd_telemetry/engine"

module InsteddTelemetry

  def self.set_add(bucket, key_attributes, element)
    SetOccurrence.find_or_create_by({
      bucket: bucket,
      key_attributes: serialize_key_attributes(key_attributes),
      element: element
    })
  end

  def self.counter_add(bucket, key_attributes, amount = 1)
    counter = Counter.find_or_initialize_by({
      bucket: bucket,
      key_attributes: serialize_key_attributes(key_attributes)
    })
    counter.add amount
    counter.save
  end

  private

  def self.serialize_key_attributes attributes
    Hash[attributes.sort].to_json
  end

end
