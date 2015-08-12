module InsteddTelemetry
  class StatModel < ActiveRecord::Base

    self.abstract_class = true

    belongs_to :period
    
    unless self.respond_to? :find_or_initialize_by
      def self.find_or_initialize_by(attributes, &block)
        where(attributes).first_or_initialize(attributes, &block)
      end
    end

    unless self.respond_to? :find_or_create_by
      def self.find_or_create_by(attributes, &block)
        where(attributes).first_or_create(attributes, &block)
      end
    end

  end
end