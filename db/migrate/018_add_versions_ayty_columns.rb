##### AYTYCRM - Silvio Fernandes #####
class AddVersionsAytyColumns < ActiveRecord::Migration

  def self.up
    add_column :versions, :ayty_default, :boolean, :default => false
    add_column :versions, :ayty_hours_provided, :float, :default => 0
    add_column :versions, :ayty_client_view_hours_provided, :boolean, :default => false
  end

  def self.down
    remove_column :versions, :ayty_default
    remove_column :versions, :ayty_hours_provided
    remove_column :versions, :ayty_client_view_hours_provided
  end

end
