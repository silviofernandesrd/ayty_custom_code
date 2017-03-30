class CreateAytyDashboardUsers < ActiveRecord::Migration
  def self.up
    create_table :ayty_dashboards_users do |t|
      t.references :ayty_dashboard, foreign_key: true
      t.references :user, foreign_key: true
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :ayty_dashboards_users
  end
end
