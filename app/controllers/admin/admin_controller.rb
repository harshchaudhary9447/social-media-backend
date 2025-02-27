module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin

    # List all users
    def index
      users = User.all
      render json: users, status: :ok
    end

    # Activate or deactivate a user
    def toggle_activation
      user = User.find_by(id: params[:id])

      if user.nil?
        return render json: { error: "User not found" }, status: :not_found
      end

      user.update(active: !user.active) # Toggle activation status
      status = user.active ? "activated" : "deactivated"

      render json: { message: "User #{status} successfully." }, status: :ok
    end

    # Assign admin role to a user
    def make_admin
      user = User.find_by(id: params[:id])

      if user.nil?
        return render json: { error: "User not found" }, status: :not_found
      end

      user.add_role(:admin)
      render json: { message: "User is now an admin." }, status: :ok
    end

    # Remove admin role from a user
    def remove_admin
      user = User.find_by(id: params[:id])

      if user.nil?
        return render json: { error: "User not found" }, status: :not_found
      end

      user.remove_role(:admin)
      render json: { message: "User is no longer an admin." }, status: :ok
    end

    private

    # Ensure only admins can access these actions
    def authorize_admin
      unless current_user.has_role?(:admin)
        render json: { error: "Unauthorized - Admins only" }, status: :unauthorized
      end
    end
  end
end
