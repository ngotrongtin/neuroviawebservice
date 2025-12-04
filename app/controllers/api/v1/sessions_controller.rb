module Api
  module V1
    class SessionsController < ActionController::API
      ACCESS_EXP = 30.minutes
      REFRESH_EXP = 30.days

      # POST /api/v1/login
      def create
        email = params[:email].to_s.downcase.strip
        password = params[:password]

        user = User.find_by('lower(email) = ?', email)

        unless user && user.valid_password?(password)
          render json: { error: 'Invalid email or password' }, status: :unauthorized and return
        end

        access_token, access_exp = build_access_token_for(user)
        refresh_rec, raw_refresh = RefreshToken.create_for(
          user: user,
          expires_in: REFRESH_EXP,
          ip: request.remote_ip,
          user_agent: request.user_agent
        )

        render json: {
          access_token: access_token,
          access_token_expires_at: access_exp.iso8601,
          refresh_token: raw_refresh,
          refresh_token_expires_at: refresh_rec.expires_at.iso8601,
          user: {
            id: user.id,
            email: user.email,
            fullname: (user.respond_to?(:fullname) ? user.fullname : nil),
            admin: (user.respond_to?(:admin?) ? user.admin? : false)
          }
        }, status: :ok
      end

      # DELETE /api/v1/logout
      # Revokes the provided refresh token (from body param or "Refresh <token>" header)
      def destroy
        raw_refresh = params[:refresh_token].presence || extract_refresh_from_header
        token_record = RefreshToken.authenticate(raw_refresh)

        if token_record&.active?
          token_record.revoke!
          render json: { success: true }, status: :ok
        else
          render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end
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

      def extract_refresh_from_header
        header = request.headers['Authorization'].to_s
        return nil if header.blank?
        scheme, tok = header.split(' ', 2)
        scheme&.downcase == 'refresh' ? tok : nil
      end
    end
  end
end
