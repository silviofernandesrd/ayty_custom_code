##### AYTYCRM - Silvio Fernandes #####
class AddCustomFieldsAytyColumns < ActiveRecord::Migration

  def self.up
    add_column :custom_fields, :ayty_deny_edit, :boolean, :default => false
    add_column :custom_fields, :ayty_show_last_update, :boolean, :default => false
  end

  def self.down
    remove_column :custom_fields, :ayty_deny_edit
    remove_column :custom_fields, :ayty_show_last_update
  end

end
