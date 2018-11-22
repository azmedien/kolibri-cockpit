class WebhooksController < ActionController::API
  include WebhooksHelper

  def receive
      @app = App.find_by_internal_id(params[:project]) or return head :not_found

      build = @app.builds.where(["platform = ?", params[:platform]]).last
      build.build_id = params[:build_id]
      build.stage = params[:stage] || 'unknown'
      build.code = params[:code] || 0
      build.message = params[:message] || 'unknown'

      is_finished = build.stage == 'publish' && build.code == 1
      build.url = is_finished ? params[:artifacts] : params[:url]

      build.save!

      ActionCable.server.broadcast 'webhooks',
        id: build.build_id,
        html: build_to_html_table_row(@app, build),
        platform: build.platform

      head @app? :ok : :not_found
  end
end
