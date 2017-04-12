class AddAssetsToApps < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :android_icon, :string
    add_column :apps, :ios_icon, :string
    add_column :apps, :splash, :string
  end
end
