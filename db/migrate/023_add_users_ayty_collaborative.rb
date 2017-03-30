class AddUsersAytyCollaborative < ActiveRecord::Migration
  def self.up
    add_column :users, :ayty_collaborative, :boolean, default: false
  end

  def self.down
    remove_column :users, :ayty_collaborative
  end
end
