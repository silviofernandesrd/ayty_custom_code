##### AYTYCRM - Silvio Fernandes #####
class AddIssuesColumnsResponsibles < ActiveRecord::Migration

  def self.up
    add_column :issues, :assigned_to_bd_id, :integer
    add_column :issues, :assigned_to_net_id, :integer
    add_column :issues, :assigned_to_test_id, :integer
    add_column :issues, :assigned_to_aneg_id, :integer
    add_column :issues, :assigned_to_areq_id, :integer
    add_column :issues, :assigned_to_inf_id, :integer
  end

  def self.down
    remove_column :issues, :assigned_to_bd_id
    remove_column :issues, :assigned_to_net_id
    remove_column :issues, :assigned_to_test_id
    remove_column :issues, :assigned_to_aneg_id
    remove_column :issues, :assigned_to_areq_id
    remove_column :issues, :assigned_to_inf_id
  end

end
