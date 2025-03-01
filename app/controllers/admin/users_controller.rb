module Admin
  class UsersController < AdminController
    before_action :authenticate_user! # Ensure authentication
    before_action :authorize_admin # Ensure only admins access this

    def index
      users = User.includes(:posts) # Fetch all users along with their posts
      render json: users, include: [ :posts ]
    end


    def toggle_activation
      user = User.find(params[:id])

      # Use the value from the request instead of just toggling
      active_status = params.dig(:user, :active)

      if active_status.nil?
        return render json: { error: "Missing 'active' parameter" }, status: :unprocessable_entity
      end

      # Convert "true"/"false" string to actual boolean
      new_status = ActiveModel::Type::Boolean.new.cast(active_status)

      user.update!(active: new_status)

      render json: { message: "User #{user.active ? 'activated' : 'deactivated'} successfully" }
    end


    def create
      user = User.new(user_params)
      if user.save
        user.add_role(params[:role]) # Assigning role
        render json: { message: "User created successfully", user: user }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end


    private

    def authorize_admin
      return if current_user.has_role?(:admin)

      render json: { error: "Access Denied" }, status: :forbidden
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :phone_number)
    end
  end
end
