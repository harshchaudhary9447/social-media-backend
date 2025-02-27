module Admin
  class UsersController < AdminController
    before_action :authenticate_user! # Ensure authentication
    before_action :authorize_admin # Ensure only admins access this

    def index
      users_with_posts = User.includes(:posts).where.not(posts: { id: nil })
      render json: users_with_posts, include: [ :posts ]
    end

    def toggle_activation
      user = User.find(params[:id])
      user.update!(active: !user.active)
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
