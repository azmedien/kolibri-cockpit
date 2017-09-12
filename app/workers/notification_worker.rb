class NotificationWorker
  include Sidekiq::Worker

  def perform(notification_id)
    notification = Notification.find(notification_id)

    if notification
      # TODO: Implement me
    end
  end
end
