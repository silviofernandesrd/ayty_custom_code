class AddJournalsAytyMarked < ActiveRecord::Migration
  def self.up
    add_column :journals, :ayty_marked, :boolean, default: false
  end

  def self.down
    remove_column :journals, :ayty_marked
  end
end
