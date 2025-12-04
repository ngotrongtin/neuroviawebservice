module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      # GET /api/v1/profile
      def show
        render json: {
          user: {
            id: current_api_user.id,
            email: current_api_user.email,
            fullname: (current_api_user.respond_to?(:fullname) ? current_api_user.fullname : nil),
            admin: (current_api_user.respond_to?(:admin?) ? current_api_user.admin? : false)
          }
        }, status: :ok
      end
    end
  end
end
