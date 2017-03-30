class AddIssuesColumnsResponsibles < ActiveRecord::Migration
  def self.up
    columns_assigned.each do |column|
      add_column :issues, column, :integer
    end
  end

  def self.down
    columns_assigned.each do |column|
      remove_column :issues, column
    end
  end

  private

  def columns_assigned
    [
      :assigned_to_bd_id,
      :assigned_to_net_id,
      :assigned_to_test_id,
      :assigned_to_aneg_id,
      :assigned_to_areq_id,
      :assigned_to_inf_id
    ]
  end
end
