class RemovePeriodFromTimespans < ActiveRecord::Migration
  def change
    remove_column :instedd_telemetry_timespans, :period_id, :integer
  end
end
