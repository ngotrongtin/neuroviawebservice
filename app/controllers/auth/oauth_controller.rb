class Auth::OauthController < ApplicationController
  def callback
    code = params[:code]  # lấy authorization code từ query param
    # ví dụ: lưu vào session hoặc xử lý tiếp
    session[:oauth_code] = code

    render plain: "Received code: #{code}"
  end
end