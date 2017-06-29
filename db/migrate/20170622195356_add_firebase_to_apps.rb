class AddFirebaseToApps < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :android_firebase, :string
    add_column :apps, :ios_firebase, :string
  end
end
