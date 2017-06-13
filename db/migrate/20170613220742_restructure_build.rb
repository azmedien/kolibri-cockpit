class RestructureBuild < ActiveRecord::Migration[5.0]
  def change
    add_column :builds, :stage, :string
    add_column :builds, :code, :integer, default: 0
    add_column :builds, :message, :string

    remove_column :builds, :build_status, :string
    remove_column :builds, :test_status, :string
    remove_column :builds, :publish_status, :string
  end
end
