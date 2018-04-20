class Notification < ApplicationRecord
  include ActionView::Helpers::DateHelper

  validates :title, presence: true
  validates :body, presence: true
  validates :url, presence: true

  validates :app, presence: true
  validates :user, presence: true

  belongs_to :app
  belongs_to :user

  belongs_to :rpush_app, class_name: 'Rpush::Client::ActiveRecord::App'
  belongs_to :rpush_notification, class_name: 'Rpush::Client::ActiveRecord::Notification', optional: true

  def is_scheduled?
    new_record? || updated_at <= scheduled_for
  end

  def status
    rpush = rpush_notification

    if rpush
      return "processed #{time_ago_in_words(updated_at)} ago" if rpush.processing
      return "delivered #{time_ago_in_words(rpush.delivered_at)} ago" if rpush.delivered
      return "failed #{time_ago_in_words(rpush.failed_at)} ago" if rpush.failed
    end

    "scheduled for #{time_ago_in_words(scheduled_for)} from now"
  end

  def delivered?
    rpush_notification && rpush_notification.delivered
  end

  def failed?
    rpush_notification && rpush_notification.failed
  end
end
