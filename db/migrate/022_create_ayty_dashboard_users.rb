class CreateAytyDashboardUsers < ActiveRecord::Migration
  
  # Criado tabela para armazenar dados para AytyDashboard
  def self.up
    create_table :ayty_dashboards_users do |t|
      t.references :ayty_dashboard, foreign_key: true
      t.references :user, foreign_key: true
      t.column :position, :integer
    end
    #add_index :ayty_dashboards_users, ["ayty_dashboard_id", "user_id"], :unique => true
  end

  def self.down
    drop_table :ayty_dashboards_users
  end
end
