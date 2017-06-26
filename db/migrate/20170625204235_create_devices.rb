class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :token, null: false, unique: true, index: true
      t.integer :platform, null: false, default: 0
      t.belongs_to :app, index: true

      t.timestamps
    end
  end
end
