class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_post, only: [ :show, :update, :destroy ]

  def index
    if current_user
      @posts = Post.includes(:comments, :likes)
                   .where("visibility = ? OR user_id = ?", "public", current_user.id)
                   .order(created_at: :desc)
    else
      @posts = Post.includes(:comments, :likes)
                   .where(visibility: "public")
                   .order(created_at: :desc)
    end

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

  def show
    if @post.nil?
      return render json: { error: "Post not found" }, status: :not_found
    end

    if @post.visibility == "private" && @post.user != current_user
      return render json: { error: "Unauthorized to view this post" }, status: :unauthorized
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

  def create
    return render json: { error: "Unauthorized - Invalid token" }, status: :unauthorized if current_user.nil?

    @post = current_user.posts.build(post_params)

    if @post.save
      render json: @post.to_json(include: { user: { only: [ :id, :first_name, :last_name ] } }), status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    return render json: { error: "Post not found" }, status: :not_found if @post.nil?

    if @post.user == current_user
      if @post.update(post_params)
        render json: @post, status: :ok
      else
        render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Not authorized to update this post" }, status: :unauthorized
    end
  end

  def destroy
    return render json: { error: "Post not found" }, status: :not_found if @post.nil?

    if @post.user == current_user
      @post.destroy
      head :no_content
    else
      render json: { error: "Not authorized to delete this post" }, status: :unauthorized
    end
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :visibility)
  end
end
