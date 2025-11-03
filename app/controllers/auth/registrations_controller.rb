# app/controllers/auth/registrations_controller.rb
class Auth::RegistrationsController < Devise::RegistrationsController
  layout 'application'

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Cho phép thêm field mới khi đăng ký
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # Redirect sau khi đăng ký
  def after_sign_up_path_for(resource)
    root_path
  end
end
