require "instedd_telemetry/engine"

module InsteddTelemetry

  def self.set_add(set_key, element_key, metadata = {})
    occurrence = SetOccurrence.find_or_initialize_by(set_key: set_key, element_key: element_key)
    occurrence.metadata ||= {}
    occurrence.metadata.merge! metadata.with_indifferent_access
    occurrence.save
  end

end
