class AppsController < ApplicationController
  before_action :set_app, only: [:show, :edit, :update, :destroy, :runtime, :build]
  before_action :set_apps, only: [:create, :new, :edit, :update, :build]
  before_filter :authenticate_user!

  require 'jenkins_api_client'

  def build
    @client = JenkinsApi::Client.new(:server_url => 'http://cimac.yanova.ch:8080/',
              :username => 'azlekov',
              :password => 'e2b06ab76712c72ace862eb6e0d536f4')
    code = @client.api_post_request(@app.android_config['jenkins_job_url'])
    raise "Could not build the job specified" unless code == '201'
  end

  # GET /apps
  # GET /apps.json
  def index
    @apps = current_user.apps
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
    redirect_to edit_app_path(@app)
  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # GET /apps/1/edit
  def edit
    respond_to do |format|
      format.json { render json: @app }
      format.html { render :edit }
    end
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
        format.html { render :edit, notice: 'App was successfully created.' }
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
        format.html { render :edit, notice: 'App was successfully updated.' }
        format.json { render json: @pp, status: :ok, location: :edit }
      else
        format.html { render :edit }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
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


  def runtime
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_params
      params.require(:app).permit(
        :internal_name,
        :internal_id,
        :runtime,
        :android_config => [:repository_url, :jenkins_job_url],
        :ios_config => [:repository_url, :jenkins_job_url])
    end
end
