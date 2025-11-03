class Admin::BaseController < ApplicationController
  layout 'admin'  
  before_action :authenticate_user!
  before_action :verify_admin
  protected

  MAX_QUERY_LENGTH = 200
  
  private

  def verify_admin
    redirect_to root_path, alert: "Access denied!" unless current_user.admin?
  end
end