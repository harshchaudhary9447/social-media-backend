class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  # def authenticate_user!
  #   puts "🔐 AUTH CHECK"
  #   unless request.headers["Authorization"].present?
  #     puts "❌ TOKEN MISSING"
  #     return render json: { error: "Token missing" }, status: :unauthorized
  #   end
  #   puts "✅ Token Found"

  #   super
  # end
end
