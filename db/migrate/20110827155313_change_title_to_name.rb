class ChangeTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :offending_sites, :title, :name
  end

  def self.down
    rename_column :offending_sites, :name, :title
  end
end
