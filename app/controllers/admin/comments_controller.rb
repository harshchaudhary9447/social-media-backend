module Admin
  class CommentsController < AdminController
    before_action :set_comment, only: [ :update, :destroy ]

    # Admin can create a comment
    def create
      @comment = Comment.new(comment_params)
      @comment.user = current_user

      if @comment.save
        render json: { message: "Comment created successfully", comment: @comment }, status: :created
      else
        render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Admin can update any comment
    def update
      if @comment.update(comment_params)
        render json: { message: "Comment updated successfully", comment: @comment }, status: :ok
      else
        render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Admin can delete any comment
    def destroy
      @comment.destroy
      render json: { message: "Comment deleted successfully" }, status: :ok
    end

    private

    def authorize_admin
      unless current_user.has_role?(:admin)
        render json: { error: "Unauthorized access" }, status: :unauthorized
      end
    end

    def set_comment
      @comment = Comment.find_by(id: params[:id])
      render json: { error: "Comment not found" }, status: :not_found unless @comment
    end

    def comment_params
      params.require(:comment).permit(:content, :post_id)
    end
  end
end
