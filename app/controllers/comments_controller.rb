# require "debug"
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [ :update, :destroy ]

  def index
    @comments = @post.comments.order(created_at: :desc)
    render json: @comments
  end

  def create
    # binding.break
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user # Associate comment with logged-in user

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    if @comment.user == current_user && @comment.update(comment_params) # Ensure only the owner can update
      render json: @comment
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end

  def destroy
    if @comment.user == current_user # Ensure only the owner can delete
      @comment.destroy
      head :no_content
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
