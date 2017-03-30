class CreateAytyIssueAlertImages < ActiveRecord::Migration
  def self.up
    create_table :ayty_issue_alert_images do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :path, :string
      t.column :filename, :string
      t.column :condition_field, :string
      t.column :condition_sign, :string
      t.column :condition_expected_value, :string
      t.column :priority_show, :integer
      t.column :active, :boolean
    end
  end

  def self.down
    drop_table :ayty_issue_alert_images
  end
end
