class AddUsersAytyDashboardPermissions < ActiveRecord::Migration
  def self.up
    add_column :users, :can_create_ayty_dashboard, :boolean, default: false
    add_column :users, :can_update_ayty_dashboard, :boolean, default: false
    add_column :users, :can_delete_ayty_dashboard, :boolean, default: false
  end

  def self.down
    remove_column :users, :can_create_ayty_dashboard
    remove_column :users, :can_update_ayty_dashboard
    remove_column :users, :can_delete_ayty_dashboard
  end
end
