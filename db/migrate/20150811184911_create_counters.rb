class CreateCounters < ActiveRecord::Migration
  def change
    create_table :instedd_telemetry_counters do |t|
      t.string  :bucket,          nullable: :false
      t.text    :key_attributes,  nullable: :false
      t.integer :count,           nullable: :false, default: 0
    end
  end
end
