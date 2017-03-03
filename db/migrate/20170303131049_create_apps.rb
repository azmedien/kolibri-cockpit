class CreateApps < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :apps do |t|
      t.string :internal_name
      t.string :internal_id
      t.json :runtime,  null: false, default: '{}'
      t.hstore :android_config, null: false, default: {}
      t.hstore :ios_config, null: false, default: {}
      t.belongs_to :user, index: true


      t.timestamps

      User.reset_column_information
    end
    add_index :apps, :internal_id
    add_index :apps, :internal_name
    add_index :apps, :android_config, using: :gin
    add_index :apps, :ios_config, using: :gin
  end
end
