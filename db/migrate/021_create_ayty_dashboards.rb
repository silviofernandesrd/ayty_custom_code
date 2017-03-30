class CreateAytyDashboards < ActiveRecord::Migration
  def self.up
    create_table :ayty_dashboards do |t|
      t.column :name, :string, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :ayty_dashboards
  end
end
