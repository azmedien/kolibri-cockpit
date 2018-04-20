class VersionsController < AppAwareController
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

  def version_params
    params.require(:version).permit(:created_at, :id)
  end
end
