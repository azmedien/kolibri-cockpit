class VersionsController < ApplicationController
  respond_to :html, :json

  before_action :set_app
  before_action :set_apps
  before_action :authenticate_user!

  authorize_actions_for :parent_resource, all_actions: :update

  def index
    @versions = @app.versions.page params[:page]
  end

  def create
    version = @app.paper_trail.version_at(version_params['created_at'])

    if version
      @app = version
    else
      version = PaperTrail::Version.find(version_params['id'])
      version = version.next if version.index == 0

      @app = version.reify
    end

    redirect_to @app if @app.save
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

  def version_params
    params.require(:version).permit(:created_at, :id)
  end
end
