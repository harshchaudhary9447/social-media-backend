class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.active? # Prevent deactivated users from logging in
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: resource,
        token: request.env["warden-jwt_auth.token"] # Retrieves JWT from Devise
      }, status: :ok
    else
      render json: { error: "Your account is deactivated. Contact admin." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: { status: 200, message: "Logged out successfully." }, status: :ok
    else
      render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
