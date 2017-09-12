class Notification < ApplicationRecord

  include ActionView::Helpers::DateHelper

  validates :title, presence: true
  validates :body, presence: true
  validates :url, presence: true

  validates :app, presence: true
  validates :user, presence: true

  belongs_to :app
  belongs_to :user

  belongs_to :rpush_app, :class_name => "Rpush::Client::ActiveRecord::App"
  belongs_to :rpush_notification, :class_name => "Rpush::Client::ActiveRecord::Notification"

  def is_scheduled?
    new_record? || self.updated_at <= self.scheduled_for
  end

  def status
    rpush = self.rpush_notification

    if rpush
      return "processed #{time_ago_in_words(self.updated_at)} ago" if rpush.processing
      return "delivered #{time_ago_in_words(rpush.delivered_at)} ago" if rpush.delivered
      return "failed #{time_ago_in_words(rpush.failed_at)} ago" if rpush.failed
    end

    "scheduled for #{time_ago_in_words(self.scheduled_for)} from now"
  end

  def delivered?
    self.rpush_notification and self.rpush_notification.delivered
  end
end
