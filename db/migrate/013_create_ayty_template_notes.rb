class CreateAytyTemplateNotes < ActiveRecord::Migration
  def self.up
    create_table :ayty_template_notes do |t|
      t.column :name, :string
      t.column :template, :text
      t.column :ayty, :boolean, default: false
      t.column :client, :boolean, default: false
    end
  end

  def self.down
    drop_table :ayty_template_notes
  end
end
