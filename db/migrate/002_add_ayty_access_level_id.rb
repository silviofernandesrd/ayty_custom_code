class AddAytyAccessLevelId < ActiveRecord::Migration
  def self.up
    add_column :attachments, :ayty_access_level_id, :integer, default: nil
    add_column :custom_fields, :ayty_access_level_id, :integer, default: nil
    add_column :journals, :ayty_access_level_id, :integer, default: nil
    add_column :users, :ayty_access_level_id, :integer, default: nil

    create_indexes
  end

  def self.down
    remove_column :attachments, :ayty_access_level_id
    remove_column :custom_fields, :ayty_access_level_id
    remove_column :journals, :ayty_access_level_id
    remove_column :users, :ayty_access_level_id
  end

  private

  def create_indexes
    add_index :attachments, [:ayty_access_level_id], name: :attachments_ayty_access_level_id
    add_index :custom_fields, [:ayty_access_level_id], name: :custom_fields_ayty_access_level_id
    add_index :journals, [:ayty_access_level_id], name: :jounals_ayty_access_level_id
    add_index :users, [:ayty_access_level_id], name: :users_ayty_access_level_id
  end
end
