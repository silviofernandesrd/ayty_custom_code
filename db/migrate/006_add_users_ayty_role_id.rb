class AddUsersAytyRoleId < ActiveRecord::Migration
  def self.up
    add_column :users, :ayty_role_id, :integer
  end

  def self.down
    remove_column :users, :ayty_role_id
  end
end
