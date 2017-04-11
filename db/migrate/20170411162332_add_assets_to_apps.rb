class AddAssetsToApps < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :android_icons, :json
    add_column :apps, :ios_icons, :json
    add_column :apps, :assets, :json
    add_column :apps, :splash, :string
  end
end
