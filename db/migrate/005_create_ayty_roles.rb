class CreateAytyRoles < ActiveRecord::Migration
  def self.up
    create_table :ayty_roles do |table|
      table.column :name, :string, null: false
      table.column :group_name, :string
      table.column :active, :boolean, default: true
    end
    create_columns_boolean
  end

  def self.down
    drop_table :ayty_roles
  end

  private

  def create_columns_boolean
    [:allowed_view_dashboard, :allowed_view_baseline,
     :allowed_send_mail_time_entries, :allowed_save_baseline,
     :allowed_to_monitor_production,
     :allowed_issues_highlights].each do |column|
       add_column :issues, column, :boolean
     end
  end
end
