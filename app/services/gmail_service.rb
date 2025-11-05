require "google/apis/gmail_v1"
require "googleauth"
require "mail"

class GmailService
  def initialize
    @user_email = Rails.application.credentials.dig(:gmail, :user_email)
    @client_id = Rails.application.credentials.dig(:gmail, :client_id)
    @client_secret = Rails.application.credentials.dig(:gmail, :client_secret)
    @refresh_token = Rails.application.credentials.dig(:gmail, :refresh_token)
  end

  def send_email(to:, subject:, body:)
    service = Google::Apis::GmailV1::GmailService.new
    service.authorization = authorize

    message = Mail.new do
      to to
      from @user_email
      subject subject
      body body
    end

    raw_message = StringIO.new(message.to_s)
    service.send_user_message("me", upload_source: raw_message, content_type: "message/rfc822")
  end

  private

  def authorize
    authorizer = Google::Auth::UserRefreshCredentials.new(
      client_id: @client_id,
      client_secret: @client_secret,
      scope: ["https://mail.google.com/"],
      refresh_token: @refresh_token
    )
    authorizer.fetch_access_token!
    authorizer
  end
end
