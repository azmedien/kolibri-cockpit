class CreateBuilds < ActiveRecord::Migration[5.0]
  def change
    create_table :builds do |t|
      t.string :build_status,       null: false, default: 'Not started'
      t.string :test_status,        null:false, default: 'Not started'
      t.string :publish_status,     null:false, default: 'Not started'
      t.string :build_id,           index: true
      t.belongs_to :app,            index: true

      t.timestamps
    end
  end
end
