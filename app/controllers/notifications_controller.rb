class NotificationsController < ApplicationController
  respond_to :html, :json

  before_action :set_app
  before_action :set_apps
  before_action :authenticate_user!
  before_action :set_nofication_app
  before_action :set_notification, only: %i[show edit update destroy]

  authorize_actions_for :parent_resource, all_actions: :notify
  authorize_actions_for :parent_resource, actions: { configure_notifications: 'notify' }

  after_action :schedule_notification, only: %i[create update]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.where(app_id: @app.id).order('scheduled_for DESC, updated_at DESC').page params[:page]
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show; end

  # GET /notifications/new
  def new
    @notification = Notification.new
    respond_modal_with @notification
  end

  # GET /notifications/1/edit
  def edit
    respond_modal_with @notification
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)
    @notification.app = @app

    if params[:send] == 'now'
      @notification.update(scheduled_for: Time.now)
    else
      @notification.update(scheduled_for: Time.parse(notification_params['scheduled_for']).utc)
    end

    @notification.user = current_user
    @notification.rpush_app = @notification_app
    @notification.save

    respond_modal_with @notification, location: app_notifications_url
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    @notification.update(notification_params)

    if params[:send] == 'now'
      @notification.update(scheduled_for: Time.now)
    else
      @notification.update(scheduled_for: Time.parse(notification_params['scheduled_for']).utc)
    end

    respond_modal_with @notification, location: app_notifications_url
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to app_notifications_url, notice: 'Notifiation was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def configure_notifications
    if @notification_app.nil?
      api_key = settings_params['firebase_server_key']

      @notification_app = Rpush::Gcm::App.new
      @notification_app.name = @app.internal_id.to_s
      @notification_app.auth_key = api_key
      @notification_app.connections = 1
      @notification_app.save!
    end

    respond_to do |format|
      format.html { redirect_to app_notifications_url, notice: 'Settings was successfully applied.' }
      format.json { head :no_content }
    end
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_nofication_app
    @notification_app = Rpush::Gcm::App.find_by_name(@app.internal_id.to_s)
  end

  def schedule_notification
    if @notification.valid?
      require 'sidekiq/api'

      jid = @notification.job_id

      if jid
        Sidekiq::ScheduledSet.new.find_job(jid).try(:delete)
        Sidekiq::Queue.new.find_job(jid).try(:delete)
      end

      job_id = NotificationWorker.perform_at(@notification.scheduled_for, @notification.id)
      @notification.update(job_id: job_id)
    end
  end

  def parent_resource
    @app
  end

  def set_app
    @app = App.with_roles(%i[admin notifier], current_user).find(params[:app_id])
  end

  def set_apps
    @apps = App.with_roles(%i[admin notifier], current_user).order(:internal_name)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit(
      :title,
      :body,
      :url,
      :send,
      :scheduled_for
    )
  end

  def settings_params
    params.require(:notification).permit(:firebase_server_key)
  end
end
