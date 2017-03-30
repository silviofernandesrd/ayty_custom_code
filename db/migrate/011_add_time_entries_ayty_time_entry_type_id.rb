class AddTimeEntriesAytyTimeEntryTypeId < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :ayty_time_entry_type_id, :integer
  end

  def self.down
    remove_column :time_entries, :ayty_time_entry_type_id
  end
end
