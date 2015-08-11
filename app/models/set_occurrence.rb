class SetOccurrence < ActiveRecord::Base
  
  self.table_name = "telemetry_set_occurrences"

  def key_attributes
    @key_attributes_hash ||= JSON.parse(super)
  end

  def self.find_or_create_occurrence(attributes, &block)
    attributes.symbolize_keys!

    key_attributes = attributes[:key_attributes]
    if key_attributes.present?
      attributes[:key_attributes] = serialize_key_attributes(key_attributes)
    end

    self.find_or_create_by(attributes, &block)
  end

  def self.serialize_key_attributes attributes
    Hash[attributes.sort].to_json
  end

  # for older rails versions
  unless self.respond_to? :find_or_create_by
    def self.find_or_create_by(attributes, &block)
      where(attributes).first_or_create(attributes, &block)
    end
  end

end