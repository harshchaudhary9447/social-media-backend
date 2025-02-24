require "debug"
puts "🔥🔥🔥 PostsController loaded 2"

class PostsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_post, only: [ :show, :update, :destroy ]

  puts "🔥🔥🔥 PostsController loaded"

  def index
    puts "CP1"
    @posts = Post.includes(:comments).order(created_at: :desc)
    puts "CP2"
    # This render function is used for returning the json data to the frontend part
    render json: @posts.to_json(include: { user: { only: [ :id, :first_name, :last_name ] }, comments: { include: { user: { only: [ :id, :first_name, :last_name ] } } } })
  end

  def show
    puts "CP3"
    render json: @posts.to_json(include: { user: { only: [ :id, :first_name, :last_name ] }, comments: { include: { user: { only: [ :id, :first_name, :last_name ] } } } })
    binding.break
  end

  def create
    puts "CP1"


    if current_user.nil?
      puts "bure chudey guru!!"
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
    if @post.user == current_user && @post.update(post_params) # Ensure only the owner can update
      render json: @post
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end

  def destroy
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
