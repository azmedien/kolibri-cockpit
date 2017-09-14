class NotificationWorker
  include Sidekiq::Worker

  # sidekiq_options :retry => false
  sidekiq_options :retry => 3, :dead => false

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)

    if notification
      n = Rpush::Gcm::Notification.new
      n.app = notification.rpush_app
      n.data = {
        component: notification.url,
        url: notification.url,
        title: notification.title,
        body: notification.body,
        to: '/topics/main'
      }
      n.notification = {
        component: notification.url,
        url: notification.url,
        title: notification.title,
        body: notification.body,
        to: '/topics/main'
      }
      n.priority = 'high'
      n.content_available = true
      n.save!

      notification.update(rpush_notification: n)
    end
  end
end
