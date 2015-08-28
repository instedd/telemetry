class AddLockToPeriod < ActiveRecord::Migration
  def change
    add_column :instedd_telemetry_periods, :lock_owner,      :string
    add_column :instedd_telemetry_periods, :lock_expiration, :datetime
  end
end
