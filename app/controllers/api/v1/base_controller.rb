module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      # Expose the currently authenticated API user
      attr_reader :current_api_user

      # Accepts `Authorization: Bearer <token>`
      def authenticate_api_user!
        header = request.headers['Authorization'].to_s
        token = nil
        if header.present? && header =~ /\ABearer (.+)\z/
          token = Regexp.last_match(1)
        end

        if token.blank?
          render json: { error: 'Missing token' }, status: :unauthorized and return
        end

        payload = decode_access_token(token)
        if payload.blank? || payload['sub'].blank?
          render json: { error: 'Invalid or expired token' }, status: :unauthorized and return
        end

        @current_api_user = User.find_by(id: payload['sub'])
        if @current_api_user.nil?
          render json: { error: 'User not found' }, status: :unauthorized
        end
      end

      def jwt_secret
        # Prefer credentials: either `credentials[:jwt][:secret]` or `credentials.jwt_secret`.
        Rails.application.credentials.dig(:jwt, :secret) || Rails.application.credentials.jwt_secret || Rails.application.secret_key_base
      end

      def decode_access_token(token)
        JWT.decode(token, jwt_secret, true, algorithm: 'HS256')[0]
      rescue JWT::ExpiredSignature, JWT::DecodeError
        nil
      end
    end
  end
end
