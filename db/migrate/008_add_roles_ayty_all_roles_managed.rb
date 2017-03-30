class AddRolesAytyAllRolesManaged < ActiveRecord::Migration
  def self.up
    add_column :roles, :ayty_all_roles_managed, :boolean
  end

  def self.down
    remove_column :roles, :ayty_all_roles_managed
  end
end
