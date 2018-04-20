class AppAwareController < ApplicationController
  respond_to :html, :json

  before_action :set_app

  private

  def parent_resource
    @app
  end

  def set_app
    @app = App.with_roles(%i[admin notifier], current_user).find(params[:app_id])
  end
end
