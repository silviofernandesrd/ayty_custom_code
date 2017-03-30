##### AYTYCRM - Silvio Fernandes #####
class AddClearValueToCopyToCustomFields < ActiveRecord::Migration

  def self.up
    change_table(:custom_fields) do |t|
      t.boolean :clear_value_to_copy, default: false
    end
  end

  def self.down
    change_table(:custom_fields) do |t|
      t.remove :clear_value_to_copy
    end
  end

end
