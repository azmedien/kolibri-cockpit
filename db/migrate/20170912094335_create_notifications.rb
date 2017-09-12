class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :app                , index: true
      t.belongs_to :user               , index: true
      t.belongs_to :rpush_notification , class_name: 'Rpush::Client::ActiveRecord::Notification'
      t.belongs_to :rpush_app          , class_name: 'Rpush::Client::ActiveRecord::App'

      t.string :title
      t.text :body
      t.string :url
      t.json :extras
      t.datetime :scheduled_for     , default: -> { 'CURRENT_TIMESTAMP' }

      t.integer :job_id

      t.timestamps
    end
  end
end
