class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    likeable = find_likeable
    like = likeable.likes.build(user: current_user)

    if like.save
      render json: { message: "Liked successfully" }, status: :created
    else
      render json: { error: like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    likeable = find_likeable
    like = likeable.likes.find_by(user: current_user)

    if like
      like.destroy
      render json: { message: "Unliked successfully" }, status: :ok
    else
      render json: { error: "Like not found or unauthorized" }, status: :not_found
    end
  end

  private

  def find_likeable
    params[:comment_id] ? Comment.find(params[:comment_id]) : Post.find(params[:post_id])
  end
end
