class RemovePeriodFromTimespans < ActiveRecord::Migration
  def up
    remove_column :instedd_telemetry_timespans, :period_id
  end

  def down
    add_column :instedd_telemetry_timespans, :period_id, :integer
  end
end
