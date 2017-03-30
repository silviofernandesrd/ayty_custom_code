##### AYTYCRM - Silvio Fernandes #####
class CreateAytyAccessLevels < ActiveRecord::Migration
  def self.up
    create_table :ayty_access_levels do |t|
      t.column :name, :string, :null => false
      t.column :level, :integer, :null => false
      t.column :ayty_access, :boolean, :default => false
    end
  end

  def self.down
    drop_table :ayty_access_levels
  end
end
