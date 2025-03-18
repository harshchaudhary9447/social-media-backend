module Admin
  class PostsController < AdminController
    before_action :set_post, only: [ :show, :update, :destroy ]

    # Admin can view all posts
    def index
      @posts = Post.includes(:user, :comments, :likes).order(created_at: :desc)

      render json: @posts.map { |post|
        post.as_json(
          include: {
            user: { only: [ :id, :first_name, :last_name ] },
            comments: {
              include: { user: { only: [ :id, :first_name, :last_name ] } },
              methods: [ :likes_count ]
            }
          },
          methods: [ :likes_count ]
        ).merge(liked_by_current_user: post.likes.exists?(user_id: current_user&.id))
      }
    end

    # Admin can view a specific post
    def show
      if @post.nil?
        return render json: { error: "Post not found" }, status: :not_found
      end

      render json: @post.as_json(
        include: {
          user: { only: [ :id, :first_name, :last_name ] },
          comments: {
            include: { user: { only: [ :id, :first_name, :last_name ] } },
            methods: [ :likes_count ]
          }
        },
        methods: [ :likes_count ]
      ).merge(liked_by_current_user: @post.likes.exists?(user_id: current_user&.id))
    end

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

    def set_post
      @post = Post.find_by(id: params[:id])
      render json: { error: "Post not found" }, status: :not_found unless @post
    end

    def post_params
      params.require(:post).permit(:title, :description)
    end
  end
end
