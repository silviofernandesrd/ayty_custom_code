##### AYTYCRM - Silvio Fernandes #####
class AddUsersAytyCollaborative < ActiveRecord::Migration

  def self.up
    add_column :users, :ayty_collaborative, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :ayty_collaborative
  end

end
