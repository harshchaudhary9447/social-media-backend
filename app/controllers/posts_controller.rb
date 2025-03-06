require "debug"
puts "🔥🔥🔥 PostsController loaded 2"

class PostsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_post, only: [ :show, :update, :destroy ]

  puts "🔥🔥🔥 PostsController loaded"


  def index
    @posts = Post.includes(:comments, :likes).order(created_at: :desc)

    render json: @posts.map { |post|
      post.as_json(
        include: {
          user: { only: [ :id, :first_name, :last_name ] },
          comments: {
            include: { user: { only: [ :id, :first_name, :last_name ] } },
            methods: [ :likes_count ] # Include likes count for comments
          }
        },
        methods: [ :likes_count ] # Include likes count for posts
      ).merge(liked_by_current_user: post.likes.exists?(user_id: current_user.id)) # Add if user liked post
    }
  end

  def show
    post = Post.includes(:comments, :likes).find(params[:id])

    render json: post.as_json(
      include: {
        user: { only: [ :id, :first_name, :last_name ] },
        comments: {
          include: { user: { only: [ :id, :first_name, :last_name ] } },
          methods: [ :likes_count ] # Include likes count for comments
        }
      },
      methods: [ :likes_count ] # Include likes count for posts
    ).merge(liked_by_current_user: post.likes.exists?(user_id: current_user.id)) # Add if user liked post
  end

  def create
    puts "CP1"


    if current_user.nil?
      puts "Aa gaya bhai"
      return render json: { error: "Unauthorized - Invalid token" }, status: :unauthorized
    end

    puts "🚀 Current User: #{current_user.email}"

    @post = current_user.posts.build(post_params)

    if @post.save
      render json: @post.to_json(include: { user: { only: [ :id, :first_name, :last_name ] } }), status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    puts "Update request received with params: #{params.inspect}"  # Debugging line

    @post = Post.find_by(id: params[:id]) # Ensure we fetch the post
    if @post.nil?
      return render json: { error: "Post not found" }, status: :not_found
    end

    if @post.user == current_user && @post.update(post_params)
      render json: @post, status: :ok  # ✅ Send updated post data
    else
      render json: { error: "Not authorized or update failed" }, status: :unauthorized
    end
  end



  def destroy
    puts "Aaa gya andar"
    # binding.break
    puts "Nikal gya bhar"
    @post = Post.find_by(id: params[:id]) # Use find_by to avoid exceptions
    if @post.nil?
      return render json: { error: "Post not found" }, status: :not_found
    end

    if @post.user == current_user # Ensure only the owner can delete
      @post.destroy
      head :no_content
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end


  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description)
  end
end

# require "debug"
# puts "🔥🔥🔥 PostsController loaded 2"

# class PostsController < ApplicationController
#   before_action :authenticate_user!
#   # before_action :set_post, only: [ :show, :update, :destroy ]

#   puts "🔥🔥🔥 PostsController loaded"

#   def update
#     puts "Update request received with params: #{params.inspect}"  # Debugging line

#     @post = Post.find_by(id: params[:id]) # Ensure we fetch the post
#     if @post.nil?
#       return render json: { error: "Post not found" }, status: :not_found
#     end

#     if @post.user == current_user && @post.update(post_params)
#       render json: @post, status: :ok  # ✅ Send updated post data
#     else
#       render json: { error: "Not authorized or update failed" }, status: :unauthorized
#     end
#   end



#   def destroy
#     puts "Aaa gya andar"
#     # binding.break
#     puts "Nikal gya bhar"
#     @post = Post.find_by(id: params[:id]) # Use find_by to avoid exceptions
#     if @post.nil?
#       return render json: { error: "Post not found" }, status: :not_found
#     end

#     if @post.user == current_user # Ensure only the owner can delete
#       @post.destroy
#       head :no_content
#     else
#       render json: { error: "Not authorized" }, status: :unauthorized
#     end
#   end


#   private

#   def set_post
#     @post = Post.find(params[:id])
#   end

#   def post_params
#     params.require(:post).permit(:title, :description)
#   end
# end
