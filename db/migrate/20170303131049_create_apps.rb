class CreateApps < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore'
    create_table :apps do |t|
      t.string :internal_name
      t.string :internal_id
      t.text :runtime
      t.text :android_config
      t.text :ios_config
      t.belongs_to :user, index: true


      t.timestamps

      User.reset_column_information
    end
    add_index :apps, :internal_id
    add_index :apps, :internal_name
    add_index :apps, :runtime, using: :gin
    add_index :apps, :android_config, using: :gin
    add_index :apps, :ios_config, using: :gin
  end
end
