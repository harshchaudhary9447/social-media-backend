module Admin
  class PostsController < AdminController
    before_action :set_post, only: [ :update, :destroy ]

    # Admin can create a post
    def create
      @post = Post.new(post_params)
      @post.user = current_user

      if @post.save
        render json: { message: "Post created successfully", post: @post }, status: :created
      else
        render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Admin can update any post
    def update
      if @post.update(post_params)
        render json: { message: "Post updated successfully", post: @post }, status: :ok
      else
        render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Admin can delete any post
    def destroy
      @post.destroy
      render json: { message: "Post deleted successfully" }, status: :ok
    end

    private

    def authorize_admin
      unless current_user.has_role?(:admin)
        render json: { error: "Unauthorized access" }, status: :unauthorized
      end
    end

    def set_post
      @post = Post.find_by(id: params[:id])
      render json: { error: "Post not found" }, status: :not_found unless @post
    end

    def post_params
      params.require(:post).permit(:title, :description)
    end
  end
end
