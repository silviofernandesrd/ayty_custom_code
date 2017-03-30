##### AYTYCRM - Silvio Fernandes #####
class AddJournalsAytyHidden < ActiveRecord::Migration

  def self.up
    add_column :journals, :ayty_hidden, :boolean, :default => false
  end

  def self.down
    remove_column :journals, :ayty_hidden
  end

end
