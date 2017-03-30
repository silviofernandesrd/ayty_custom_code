##### AYTYCRM - Silvio Fernandes #####
class CreateAytyLastnames < ActiveRecord::Migration

  def self.up
    create_table :ayty_lastnames do |t|
      t.column :lastname, :string
      t.column :active, :boolean, :default => true

      #t.timestamps
    end

  end

  def self.down
    drop_table :ayty_lastnames
  end
end
