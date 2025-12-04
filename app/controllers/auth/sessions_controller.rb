# app/controllers/auth/sessions_controller.rb
class Auth::SessionsController < Devise::SessionsController
  layout 'application' 

  protected

  # redirect after login
  def after_sign_in_path_for(resource)
    admin_root_path
  end

  # redirect after logout
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
