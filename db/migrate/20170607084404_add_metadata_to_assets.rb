class AddMetadataToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column :assets, :content_type, :string
    add_column :assets, :file_size, :integer

    say_with_time "Updating content type and file size of existing assets..." do
      Asset.where(content_type: nil).find_each do |asset|
        asset.update_attribute :content_type, asset.file.content_type == 'application/octet-stream' || asset.file.content_type.blank? ? MIME::Types.type_for(original_filename).first : asset.file.content_type
        asset.update_attribute :file_size, asset.file.size
      end
    end
  end
end
