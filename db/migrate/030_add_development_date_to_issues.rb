class AddDevelopmentDateToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :development_date, :datetime
  end
end
