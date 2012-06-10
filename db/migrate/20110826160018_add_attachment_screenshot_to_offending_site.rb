class AddAttachmentScreenshotToOffendingSite < ActiveRecord::Migration
  def self.up
    add_column :offending_sites, :screenshot_file_name, :string
    add_column :offending_sites, :screenshot_content_type, :string
    add_column :offending_sites, :screenshot_file_size, :integer
    add_column :offending_sites, :screenshot_updated_at, :datetime
  end

  def self.down
    remove_column :offending_sites, :screenshot_file_name
    remove_column :offending_sites, :screenshot_content_type
    remove_column :offending_sites, :screenshot_file_size
    remove_column :offending_sites, :screenshot_updated_at
  end
end
