module InsteddTelemetry
  class BaseTracker < BaseModel
    self.abstract_class = true

    include StatUtils

    before_create :set_key_attributes_hash

    private

    def set_key_attributes_hash
      self.key_attributes_hash = Digest::SHA256.hexdigest self.key_attributes
    end
  end
end
