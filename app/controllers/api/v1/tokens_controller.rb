module Api
  module V1
    class TokensController < ActionController::API
      ACCESS_EXP = 15.minutes
      REFRESH_EXP = 30.days

      # POST /api/v1/refresh
      # Exchanges a valid refresh token for a new access token and rotated refresh token
      def create
        raw_refresh = params[:refresh_token].to_s
        record = RefreshToken.authenticate(raw_refresh)

        unless record&.active?
          render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized and return
        end

        user = record.user
        # Rotate refresh token
        record.revoke!
        new_record, new_raw = RefreshToken.create_for(
          user: user,
          expires_in: REFRESH_EXP,
          ip: request.remote_ip,
          user_agent: request.user_agent
        )

        access_token, access_exp = build_access_token_for(user)

        render json: {
          access_token: access_token,
          access_token_expires_at: access_exp.iso8601,
          refresh_token: new_raw,
          refresh_token_expires_at: new_record.expires_at.iso8601
        }, status: :ok
      end

      private

      def jwt_secret
        Rails.application.credentials.dig(:jwt, :secret) || Rails.application.credentials.jwt_secret || Rails.application.secret_key_base
      end

      def build_access_token_for(user)
        exp_time = Time.current + ACCESS_EXP
        token = JWT.encode(
          { sub: user.id, iat: Time.current.to_i, exp: exp_time.to_i, jti: SecureRandom.uuid },
          jwt_secret,
          'HS256'
        )
        [token, exp_time]
      end
    end
  end
end
