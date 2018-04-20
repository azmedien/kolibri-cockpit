class VersionsController < ApplicationController
  respond_to :html, :json

  before_action :set_app
  before_action :set_apps
  before_action :authenticate_user!

  authorize_actions_for :parent_resource, all_actions: :update

  def index
    @versions = @app.versions.page params[:page]
  end

  private

  def set_app
    @app = App.with_roles(%i[admin notifier], current_user).find(params[:app_id])
  end

  def set_apps
    @apps = App.with_roles(%i[admin notifier], current_user).order(:internal_name)
  end

  def parent_resource
    @app
  end
end
