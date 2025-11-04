class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:update, :destroy]
  def index
    @users = User.search(fullname: params[:fullname], email: params[:email]).page(params[:page]).per(20)
  end

  def destroy 
    @user.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_users_path, notice: "User deleted successfully." }
    end
  end

  def update 
    @user.update(admin: !@user.admin)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_users_path }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
