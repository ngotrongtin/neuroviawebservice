class Auth::PasswordsController < Devise::PasswordsController
  def new
    super
  end

  def create
    user = User.find_by(email: resource_params[:email])

    if user.present?
      token = user.send_reset_password_instructions

      reset_link = edit_user_password_url(reset_password_token: token)

      GmailService.new.send_email(
        to: user.email,
        subject: "Reset your password",
        body: <<~BODY
          Hi #{user.email},

          We received a request to reset your password.
          Click the link below to set a new one:

          #{reset_link}

          If you didn’t request this, please ignore this email.
        BODY
      )

      set_flash_message!(:notice, :send_instructions)
      redirect_to new_session_path(resource_name)
    else
      self.resource = resource_class.new
      flash.now[:alert] = "Email not found"
      render :new
    end
  end
end
