class AddUsersAytyColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :has_view_time_tracker, :boolean, default: false
    add_column :users, :days_to_block_retroactive_time_entry, :integer, default: false
    add_column :users, :maximum_hours_allowed_to_time_entry_per_day, :integer, default: false
    add_column :users, :productive_hours, :float
    add_column :users, :days_of_vacation, :integer, default: false
    add_column :users, :is_business_partner, :boolean, default: false
    add_column :users, :code_user, :string, limit: 10, default: false
    add_column :users, :date_admission, :date
    add_column :users, :function_name, :string, default: ''
  end

  def self.down
    remove_column :users, :has_view_time_tracker
    remove_column :users, :days_to_block_retroactive_time_entry
    remove_column :users, :maximum_hours_allowed_to_time_entry_per_day
    remove_column :users, :productive_hours
    remove_column :users, :days_of_vacation
    remove_column :users, :is_business_partner
    remove_column :users, :code_user
    remove_column :users, :date_admission
    remove_column :users, :function_name
  end
end
