module InsteddTelemetry
  class BaseModel < ActiveRecord::Base

    self.abstract_class = true

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

    def self.mass_assignment?
      !"ActiveModel::MassAssignmentSecurity".constantize.nil? rescue false
    end

    # Disable attr_accessible by protecting nothing
    attr_protected if mass_assignment?

  end
end
