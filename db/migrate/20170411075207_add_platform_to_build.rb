class AddPlatformToBuild < ActiveRecord::Migration[5.0]
  def change
    add_column :builds, :platform, :string, null: false, default: 'unknown'

    add_index :builds, [:platform, :build_id], unique: true
  end
end
