# This migration comes from instedd_telemetry (originally 20150812183344)
class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :instedd_telemetry_periods do |t|
      t.datetime :beginning, nullable: false
      t.datetime :end,       nullable: false
      t.timestamps
    end
  end
end
