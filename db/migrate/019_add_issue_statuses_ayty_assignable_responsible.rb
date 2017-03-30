##### AYTYCRM - Silvio Fernandes #####
class AddIssueStatusesAytyAssignableResponsible < ActiveRecord::Migration

  def self.up
    add_column :issue_statuses, :ayty_assignable_responsible, :boolean, :default => false
  end

  def self.down
    remove_column :issue_statuses, :ayty_assignable_responsible
  end

end
