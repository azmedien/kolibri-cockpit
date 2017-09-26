class AssetsController < ApplicationController

  before_action :authenticate_user!, except: [:download]
  before_action :set_app
  before_action :set_apps
  before_action :set_asset, only: [:show, :edit, :update, :destroy, :download]

  authorize_actions_for :parent_resource, all_actions: :build, :except => :download

  respond_to :html, :json


  # GET /assets
  # GET /assets.json
  def index
    @assets = @app.assets
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
  end

  # GET /assets/new
  def new
    @asset = Asset.new
    respond_modal_with @asset
  end

  # GET /assets/1/edit
  def edit
    respond_modal_with @asset
  end

  # POST /assets
  # POST /assets.json
  def create
    assets = Array.new

    asset_params[:file].each do |file|
      asset = Asset.new(file: file, app_id: @app.id)
      assets << asset
    end

    assets.each do |asset|
      if !asset.save
        @asset.errors.add(:base, :unprocessable_entity)
        respond_modal_with [@app, @asset], location: :new
        return
      end
    end

    respond_modal_with [@app, @asset], location: app_assets_url
  end

  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  def update
    if @asset.update(file: asset_params[:file].first)
      respond_modal_with [@app, @asset], location: app_assets_url
    else
      @asset.errors.add(:base, :unprocessable_entity)
      respond_modal_with @asset
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.json
  def destroy
    @asset.destroy
    respond_to do |format|
      format.html { redirect_to app_assets_url, notice: 'Asset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download
    puts params
    if params[:variant].nil?
      redirect_to @asset.file.url
    else
      version = params[:variant]
      redirect_to @asset.file.versions[version.to_sym].url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.friendly.find_by!(slug: params[:id] || params[:asset_id], app_id: @app.id)
    end

    def parent_resource
      @app
    end

    def set_app
      @app = App.with_roles([:admin, :notifier], current_user).find(params[:app_id])
    end

    def set_apps
      @apps = App.with_roles([:admin, :notifier], current_user).order(:internal_name)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      params.require(:asset).permit(:file => [])
    end
end
