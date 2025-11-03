class Admin::UsersController < Admin::BaseController
  def index
    @users = User.search(fullname: params[:fullname], email: params[:email]).page(params[:page]).per(20)
  end
end
