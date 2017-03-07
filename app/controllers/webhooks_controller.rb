class WebhooksController < ActionController::API
  include WebhooksHelper
  def receive
      @app = App.find_by_internal_id(params[:project]) or return head :not_found

      build = @app.builds.find_or_create_by(build_id: params[:build])

      begin
        build.send(params[:type].downcase + '_status=', params[:status])
      rescue
      end

      build.save

      ActionCable.server.broadcast 'webhooks',
        id: build.build_id,
        html: build_to_html_table_row(build)

      head @app? :ok : :not_found
  end
end
