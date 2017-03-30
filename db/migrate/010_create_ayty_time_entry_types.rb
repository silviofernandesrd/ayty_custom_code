##### AYTYCRM - Silvio Fernandes #####
class CreateAytyTimeEntryTypes < ActiveRecord::Migration

  def self.up
    create_table :ayty_time_entry_types do |t|
      t.column :name, :string, :default => "", :null => false
      t.column :position, :integer, :default => 1
      t.column :active, :boolean, :default => true, :null => false
      t.column :code, :string
      t.column :client, :boolean, :default => true, :null => false

      #t.timestamps
    end

  end

  def self.down
    drop_table :ayty_time_entry_types
  end
end
