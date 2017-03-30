##### AYTYCRM - Silvio Fernandes #####
class CreateAytyRoles < ActiveRecord::Migration

  def self.up
    create_table :ayty_roles do |t|
      t.column :name, :string, :null => false
      t.column :group_name, :string
      t.column :active, :boolean, :default => true
      t.column :allowed_view_dashboard, :boolean
      t.column :allowed_view_baseline, :boolean
      t.column :allowed_send_mail_time_entries, :boolean
      t.column :allowed_save_baseline, :boolean
      t.column :allowed_to_monitor_production, :boolean
      t.column :allowed_issues_highlights, :boolean
    end
  end

  def self.down
    drop_table :ayty_roles
  end

end
