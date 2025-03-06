class AddDurationToSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :sleep_records, :duration, :integer, default: 0, null: false, after: :wake_up_at
  end
end
