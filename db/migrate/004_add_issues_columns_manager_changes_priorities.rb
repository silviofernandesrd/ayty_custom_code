##### AYTYCRM - Silvio Fernandes #####
class AddIssuesColumnsManagerChangesPriorities < ActiveRecord::Migration

  def self.up
    add_column :issues, :ayty_manager_priority_user_id, :integer
    add_column :issues, :ayty_manager_priority_date, :datetime
  end

  def self.down
    remove_column :issues, :ayty_manager_priority_user_id
    remove_column :issues, :ayty_manager_priority_date
  end

end
