class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :instedd_telemetry_periods do |t|
      t.datetime :beginning, nullable: false
      t.datetime :end,       nullable: false
      t.datetime :stats_sent_at
      t.timestamps null: false
    end
  end
end
