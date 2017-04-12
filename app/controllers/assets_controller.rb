class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :edit, :update, :destroy]
  before_action :set_app
  before_action :set_apps

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
  end

  # GET /assets/1/edit
  def edit
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = Asset.new(asset_params)
    @asset.app_id = @app.id

    respond_to do |format|
      if @asset.save
        format.html { redirect_to [@app, @asset], notice: 'Asset was successfully created.' }
        format.json { render :show, status: :created, location: [@app, @asset] }
      else
        format.html { render :new }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  def update
    respond_to do |format|
      if @asset.update(asset_params)
        format.html { redirect_to [@app, @asset], notice: 'Asset was successfully updated.' }
        format.json { render :show, status: :ok, location: [@app, @asset] }
      else
        format.html { render :edit }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def set_app
      @app = App.find(params[:app_id])
    end

    def set_apps
      @apps = current_user.apps
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      params.require(:asset).permit(:file)
    end
end
