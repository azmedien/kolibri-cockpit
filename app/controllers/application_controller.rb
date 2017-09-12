class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  add_flash_types :success, :warning, :danger, :info

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_apps

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  def not_found
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  def error
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/500", layout: false, status: :error }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  def set_apps
    if user_signed_in?
      @apps = current_user.apps
    end
  end
end
