class Notification < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  validates :url, presence: true

  validates :app, presence: true
  validates :user, presence: true

  belongs_to :app
  belongs_to :user

  def is_scheduled?
    new_record? || self.updated_at <= self.scheduled_for
  end
end
