class CreateAytyManagedUsers < ActiveRecord::Migration
  def self.up
    create_table :ayty_managed_users, id: false do |t|
      t.column :user_id, :integer
      t.column :managed_user_id, :integer
      t.column :author_id, :integer
    end
    add_index :ayty_managed_users, [:user_id, :managed_user_id], unique: true
  end

  def self.down
    drop_table :ayty_managed_users
  end
end
