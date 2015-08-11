class SetOccurrence < ActiveRecord::Base
  
  serialize :metadata, JSON

  # for older rails versions
  unless self.respond_to? :find_or_initialize_by
    def self.find_or_initialize_by(attributes, &block)
      where(attributes).first_or_initialize(attributes, &block)
    end
  end

end