require "instedd_telemetry/engine"

module InsteddTelemetry

  def self.set_add(bucket, key_attributes, element)
    SetOccurrence.find_or_create_occurrence({
      bucket: bucket,
      key_attributes: key_attributes,
      element: element
    })
  end

end
