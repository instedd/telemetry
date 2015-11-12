# This migration comes from instedd_telemetry (originally 20151112170121)
class RemovePeriodFromTimespans < ActiveRecord::Migration
  def change
    remove_column :instedd_telemetry_timespans, :period_id, :integer
  end
end
