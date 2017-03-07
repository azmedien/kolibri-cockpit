class WebhooksChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'webhooks'
  end
end
