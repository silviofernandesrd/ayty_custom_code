class CreateAytyManagedRoles < ActiveRecord::Migration
  def self.up
    create_table :ayty_managed_roles, id: false do |table|
      table.integer :role_id, null: false
      table.integer :managed_role_id, null: false
    end
    add_index :ayty_managed_roles, [:role_id, :managed_role_id], unique: true
  end

  def self.down
    drop_table :ayty_managed_roles
  end
end
