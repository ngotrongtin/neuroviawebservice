# app/controllers/auth/registrations_controller.rb
class Auth::RegistrationsController < Devise::RegistrationsController
  layout 'application'

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Allow additional fields during sign up
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # Redirect after sign up
  def after_sign_up_path_for(resource)
    root_path
  end
end
