##### AYTYCRM - Silvio Fernandes #####
class AddAssignedToVersions < ActiveRecord::Migration

  def self.up
    add_reference :versions, :assigned_to, references: :users, index: true
  end

  def self.down
    change_table(:versions) do |t|
      t.remove :assigned_to_id
    end
  end

end
