class AddMetadataToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column :assets, :content_type, :string
    add_column :assets, :file_size, :integer
    add_column :assets, :slug, :string, unique: true
  end
end
