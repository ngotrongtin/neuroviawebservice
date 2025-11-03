class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all_users
  end
end
