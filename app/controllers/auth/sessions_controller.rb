# app/controllers/auth/sessions_controller.rb
class Auth::SessionsController < Devise::SessionsController
  layout 'application' 

  # GET /users/sign_in
  def new
    super
  end

  # POST /users/sign_in
  def create
    super
  end

  # DELETE /users/sign_out
  def destroy
    super
  end

  protected

  # Sau khi đăng nhập xong thì redirect đến đâu
  def after_sign_in_path_for(resource)
    admin_root_path # hoặc root_path tuỳ app của bạn
  end

  # Sau khi đăng xuất
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
