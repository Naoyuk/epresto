# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end

  def after_sign_in_path_for(_resource)
    profile_path
  end

  protected

  def configure_permitted_parameters
    sign_up_params = %i[name vendor_id sysadmin]
    devise_parameter_sanitizer.permit(:sign_up, keys: sign_up_params)
  end
end
