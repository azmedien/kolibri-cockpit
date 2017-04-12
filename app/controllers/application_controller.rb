class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :danger, :info
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_apps

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  def set_apps
    if user_signed_in?
      @apps = current_user.apps
    end
  end
end
