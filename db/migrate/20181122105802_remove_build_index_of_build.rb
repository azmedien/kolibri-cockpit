class RemoveBuildIndexOfBuild < ActiveRecord::Migration[5.2]
  def change
    remove_index :builds, column: [:platform, :build_id], unique: true
  end
end
