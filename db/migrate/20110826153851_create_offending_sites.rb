class CreateOffendingSites < ActiveRecord::Migration
  def self.up
    create_table :offending_sites do |t|
      t.string :url, :limit => 255
      t.text :description
      t.string :title, :limit => 255
      t.string :email, :limit => 1024
      t.boolean :is_published, :default => false
      t.datetime :published_at, :null => true

      t.timestamps
    end
  end

  def self.down
    drop_table :offending_sites
  end
end
