class AppsController < ApplicationController
  before_action :authenticate_user!, except: [:runtime]
  before_action :set_app, except: %i[index create new runtime]
  before_action :set_apps, except: %i[show destroy jenkins runtime]

  authority_actions settings: 'update',
                    build: 'build',
                    prepare: 'prepare',
                    publish: 'publish',
                    configure_app: 'publish'

  respond_to :html, :json

  # GET /apps
  # GET /apps.json
  def index; end

  # GET /apps/1
  # GET /apps/1.json
  def show
    redirect_to settings_app_path(@app)
  end

  # GET /apps/new
  def new
    @app = App.new
    respond_modal_with @app
  end

  # POST /apps
  # POST /apps.json
  def create
    if params[:create] == 'existing'
      @app = App.new(app_params)
      origin = @apps.find(params[:origin])

      @app.runtime = origin.runtime.dup
      @app.android_config = origin.android_config.dup
      @app.ios_config = origin.ios_config.dup
      @app.android_icon = origin.android_icon.dup
      @app.ios_icon = origin.ios_icon.dup

      @app.splash = origin.splash.dup

      @app.android_config['origin'] = origin.id
      @app.ios_config['origin'] = origin.id
      @app.android_config.delete('bundle_id')
      @app.ios_config.delete('bundle_id')

      @app.duplicate_files(origin)
    else
      @app = App.new(app_params)
    end

    @app.user = current_user

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
    end

    respond_modal_with @app, location: @app
  end

  # PATCH/PUT /apps/1
  # PATCH/PUT /apps/1.json
  def update
    authorize_action_for @app

    respond_to do |format|
      if app_params[:android_config].present? && app_params[:android_config][:bundle_id].present?
        if (@app.android_config['bundle_id'] != app_params[:android_config][:bundle_id]) && App.android_bundle_id?(app_params[:android_config][:bundle_id])
          @app.errors.add(:base, 'Android bundle id is invalid or already used')
        end
      end

      if app_params[:ios_config].present? && app_params[:ios_config][:bundle_id].present?
        if (@app.ios_config['bundle_id'] != app_params[:ios_config][:bundle_id]) && App.ios_bundle_id?(app_params[:ios_config][:bundle_id])
          @app.errors.add(:base, 'iOS bundle id is invalid or already used')
        end
      end

      if !@app.errors.full_messages.present? && @app.update(app_params)
        format.html { redirect_to request.referrer, notice: 'App was successfully updated.' }
        format.json { render json: @app, status: :ok, location: :edit }
      else
        format.html { render :settings }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /apps/1/edit
  def edit
    redirect_to(settings_app_path(@app)) && return if current_user.has_role?(:admin, @app)
    redirect_to(app_notifications_path(@app)) && return if current_user.can_notify?(@app)
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    authorize_action_for @app

    if @app.deletable_by?(current_user)
      @notification.destroy if @notification
      @app.destroy
      respond_to do |format|
        format.html { redirect_to apps_url, notice: 'App was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to apps_url, danger: 'You cannot delete this application.' }
        format.json { head :no_content }
      end
    end
  end

  def settings
    authorize_action_for @app

    respond_to do |format|
      format.json { render json: @app }
      format.html { render :settings }
    end
  end

  def build
    authorize_action_for @app
  end

  def prepare
    authorize_action_for @app
  end

  def publish
    authorize_action_for @app
  end

  def runtime
    # Ensure we return in all cases an app.
    # This is used now to provide runtime configuraiton without any
    # authentication. This must be repalced with some kind of authentication
    @app = App.find(params[:id])
    render json: @app.runtime
  end

  def configure_app
    authorize_action_for @app

    redirect_to request.referrer
    ConfigureAppJob.set(wait: 2.seconds).perform_later @app, configure_params.to_h, current_user
  end

  def invite
    unless request.xhr?

      email = params[:app][:invite]
      role = params[:role]

      user = User.find_by_email(email)

      unless user
        invited = User.invite!({ email: email, skip_invitation: true }, current_user)
        invited.add_role role, @app

        respond_to do |format|
          format.html do
            redirect_to request.referrer,
                        notice: "An invitation email will be sent to #{email}"
          end
        end

        return
      end

      already_invated = user.has_role?(role, @app) || @app.user == user

      if already_invated
        respond_to do |format|
          format.js
          format.html do
            redirect_to request.referrer,
                        alert: "User with email #{email} already invited for this role"
          end
        end
      else
        user.add_role :admin, @app
        respond_to do |format|
          format.js
          format.html do
            redirect_to request.referrer,
                        notice: "User with email #{email} successfully invited for this role"
          end
        end
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_app
    @app = App.with_roles(%i[admin notifier], current_user).find(params[:id] || params[:app_id])
  end

  def set_apps
    @apps = App.with_roles(%i[admin notifier], current_user).order(:internal_name)
  end

  def configure_params
    params.permit(
      :utf8,
      :authenticity_token,
      :platform,
      :commit,
      :id,
      channels: [],)
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
      android_config: %i[repository_url publishing_profile bundle_id version_code version_name],
      ios_config: %i[repository_url publishing_profile bundle_id version_code version_name]
    )
  end
end
