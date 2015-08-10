# This migration comes from instedd_telemetry (originally 20150810180903)
class CreateSets < ActiveRecord::Migration
  def change
    create_table :set_occurrences do |t|
      t.string :set_key,     nullable: false
      t.string :element_key, nullable: false
      t.text   :metadata
    end
  end
end
