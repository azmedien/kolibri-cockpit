class AppsController < ApplicationController
  before_action :authenticate_user!, except: [:runtime]
  before_action :set_app, only: [:show, :edit, :update, :destroy, :build, :settings, :prepare, :publish]
  before_action :set_apps, only: [:index, :create, :new, :edit, :update, :build, :settings, :prepare, :publish]
  before_action :set_jenkins
  before_action :set_jenkins_job, only: [:create, :update, :build]

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

      notice = 'Application was successfully duplicated.'
    else
      @app = App.new(app_params)
      notice = 'Application was successfully created.'
    end

    @app.user = current_user

    respond_to do |format|
      if @app.save
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

  def runtime
    # Ensure we return in all cases an app.
    # This is used now to provide runtime configuraiton without any
    # authentication. This must be repalced with some kind of authentication
    @app = App.find(params[:id])
    render json: @app.runtime
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = current_user.apps.find(params[:id])
    end

    def set_apps
      @apps = current_user.apps
    end

    def set_jenkins
      require 'jenkins_api_client'
      @client = JenkinsApi::Client.new(
                :server_url => Rails.configuration.cockpit['jenkins_url'],
                :username => Rails.configuration.cockpit['jenkins_user'],
                :password => Rails.configuration.cockpit['jenkins_secret'])
    end

    def set_jenkins_job
      begin
        @jobs = @client.job.list_all
      rescue Exception => e
        flash[:danger] = e.message
        redirect_to request.referrer
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_params
      params.require(:app).permit(
        :internal_name,
        :internal_id,
        :runtime,
        :android_icon,
        :ios_icon,
        :splash,
        :android_config => [:repository_url, :jenkins_job, :netmetrix_ua, :netmetrix_url],
        :ios_config => [:repository_url, :jenkins_job, :netmetrix_ua, :netmetrix_url])
    end
end
