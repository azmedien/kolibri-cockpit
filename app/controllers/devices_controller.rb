class DevicesController < ApplicationController
  before_action :set_app
  before_action :set_apps
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  rescue_from ActionController::ParameterMissing do
    render :nothing => true, :status => 400
  end

  # GET /devices
  # GET /devices.json
  def index
    @devices = @app.devices
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)
    @device.app_id = @app.id

    respond_to do |format|
      if @device.save
        format.html { redirect_to [@app, @device], notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: [@app, @device] }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to [@app, @device], notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: [@app, @device] }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to app_devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    def set_app
      @app = App.find(params[:app_id])
    end

    def set_apps
      @apps = current_user.apps if current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:token, :platform)
    end
end
