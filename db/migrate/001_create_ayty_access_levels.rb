class CreateAytyAccessLevels < ActiveRecord::Migration
  def self.up
    create_table :ayty_access_levels do |table|
      table.column :name, :string, null: false
      table.column :level, :integer, null: false
      table.column :ayty_access, :boolean, default: false
    end
  end

  def self.down
    drop_table :ayty_access_levels
  end
end
