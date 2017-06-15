module ApplicationHelper
  def gravatar_url(email, size)
    gravatar = Digest::MD5::hexdigest(email).downcase
    url = "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
    url
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def send_cable
    html = render_message('message', 'warning')
    ActionCable.server.broadcast 'app_configure',
      html: html
  end

  def render_message message, type
    ApplicationController.renderer.render({
      partial: 'layouts/notification',
      locals: { message: message, type: type }
    })
  end
end
