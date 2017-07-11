class AppsController < ApplicationController
  before_action :authenticate_user!, except: [:runtime]
  before_action :set_app, except: [:index, :create, :new, :runtime]
  before_action :set_apps, except: [:show, :destroy, :jenkins, :runtime]
  before_action :set_nofication_app, only: [:notifications, :send_notifications, :destroy]
  before_action :set_nofications, only: [:notifications, :send_notifications]

  # GET /apps
  # GET /apps.json
  def index
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
    redirect_to settings_app_path(@app)
  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # POST /apps
  # POST /apps.json
  def create
    if params[:create] == 'existing'
      @app = App.new(app_params)
      origin = current_user.apps.find(params[:origin])

      @app.runtime = origin.runtime.dup
      @app.android_config = origin.android_config.dup
      @app.ios_config = origin.ios_config.dup
      @app.android_icon = origin.android_icon.dup
      @app.ios_icon = origin.ios_icon.dup

      @app.android_config['origin'] = origin.id
      @app.ios_config['origin'] = origin.id
      @app.android_config.delete('bundle_id')
      @app.ios_config.delete('bundle_id')

      @app.duplicate_files(origin)

      notice = 'Application was successfully duplicated.'
    else
      @app = App.new(app_params)
      notice = 'Application was successfully created.'
    end

    @app.user = current_user

    respond_to do |format|
      if @app.save

        if origin
          origin.assets.each do |item|
            asset = Asset.new
            asset.app_id = @app.id
            asset.slug = item.slug
            asset.duplicate_file(item)
            asset.save!
          end
        end

        format.html { redirect_to settings_app_path(@app), notice: 'App was successfully created.' }
        format.json { render json: @app, status: :created, location: :edit }
      else
        format.html { render :new }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apps/1
  # PATCH/PUT /apps/1.json
  def update
    respond_to do |format|

      if @app.update(app_params)
        format.html { redirect_to settings_app_path(@app), notice: 'App was successfully updated.' }
        format.json { render json: @app, status: :ok, location: :edit }
      else
        format.html { render :settings }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /apps/1/edit
  def edit
    redirect_to settings_app_path(@app)
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @notification.destroy if @notification
    @app.destroy
    respond_to do |format|
      format.html { redirect_to apps_url, notice: 'App was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /apps/1/jenkins
  def jenkins
    begin
      if :type == 'android'
        code = @client.job.build(@app.android_config['jenkins_job'])
      else
        code = @client.job.build(@app.ios_config['jenkins_job'])
      end

    rescue Exception => e
      flash[:danger] = e.message
      redirect_to request.referrer
    end
    # raise "Could not build the job specified" unless code == '201'
  end

  def settings
    respond_to do |format|
      format.json { render json: @app }
      format.html { render :settings }
    end
  end

  def build

  end

  def prepare

  end

  def publish

  end

  def notifications
  end

  def send_notifications
    if @notification.nil?
      api_key = notification_params['firebase_server_key']

      @notification = Rpush::Gcm::App.new
      @notification.name = "#{@app.internal_id}"
      @notification.auth_key = api_key
      @notification.connections = 1
      @notification.save!
    end

    n = Rpush::Gcm::Notification.new
    n.app = @notification
    n.data = {
      component: "#{notification_params['url']}",
      title: notification_params['title'],
      body: notification_params['message'],
      to: '/topics/main'
    }
    n.priority = 'high'
    n.content_available = true
    n.notification = { title: notification_params['title'],
                       body: notification_params['message']
                     }
    n.save!

    respond_to do |format|
      format.html { redirect_to notifications_app_path(@app), notice: 'Notification send' }
    end
  end

  def runtime
    # Ensure we return in all cases an app.
    # This is used now to provide runtime configuraiton without any
    # authentication. This must be repalced with some kind of authentication
    @app = App.find(params[:id])
    render json: @app.runtime
  end

  def configure_app
    ConfigureAppJob.perform_later @app, params['platform'] || 'both', current_user
    flash[:notice] = 'Publish scheduled...'
    redirect_to request.referrer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = current_user.apps.find(params[:id])
    end

    def set_nofication_app
      @notification = Rpush::Gcm::App.find_by_name("#{@app.internal_id}")
    end

    def set_nofications
      @notifications = Rpush::Gcm::Notification.where(app_id: @notification.id).last(10).reverse if @notification
      @notifications = Array.new unless @notifications
    end

    def set_apps
      @apps = current_user.apps.order(:internal_name)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_params
      params.require(:app).permit(
        :internal_name,
        :internal_id,
        :runtime,
        :android_icon,
        :android_firebase,
        :ios_firebase,
        :ios_icon,
        :splash,
        :android_config => [:repository_url, :bundle_id, :version_code, :version_name],
        :ios_config => [:repository_url, :bundle_id, :version_code, :version_name])
    end

    def notification_params
      params.require(:notification).permit(
        :firebase_server_key,
        :url,
        :title,
        :message
      )
    end
end
