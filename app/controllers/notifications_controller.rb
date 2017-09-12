class NotificationsController < ApplicationController

  respond_to :html, :json

  before_action :set_app
  before_action :set_apps
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end

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
    @notification.user = current_user
    @notification.save

    respond_modal_with @notification, location: app_notifications_url
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    @notification.update(notification_params)
    respond_modal_with @notification, location: app_notifications_url
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    def set_app
      @app = App.find(params[:app_id])
    end

    def set_apps
      @apps = current_user.apps if current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(
        :title,
        :body,
        :url,
        :send,
        :scheduled_for)
    end
end
