class AppConfigureChannel < ApplicationCable::Channel

  def subscribed
    stream_from 'app_configure'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
