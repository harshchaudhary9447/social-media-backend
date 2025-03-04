require "rubygems"
require "csv"


module Admin
  class ReportsController < AdminController
    # Uncomment if authentication and authorization are required
    # before_action :authenticate_user!
    # before_action :authorize_admin

    # 1. Report of all users with post and comment count
    def users_report
      users = User.left_joins(:posts, :comments)
                  .select("users.id, users.email, users.first_name, users.last_name, COUNT(DISTINCT posts.id) AS posts_count, COUNT(DISTINCT comments.id) AS comments_count")
                  .group("users.id")

      if request.format.csv?
        send_data generate_csv(users), filename: "users_report.csv"
      elsif request.format.xlsx?
        send_data generate_xlsx(users, "Users Report"), filename: "users_report.xlsx"
      else
        render json: { error: "Unsupported format" }, status: :bad_request
      end
    end

    # 2. Report of users with more than 10 posts
    def active_users_report
      users = User.left_joins(:posts)
                  .select("users.id, users.email, users.first_name, users.last_name, COUNT(posts.id) AS posts_count")
                  .group("users.id")
                  .having("COUNT(posts.id) > 10")

      if request.format.csv?
        send_data generate_csv(users), filename: "active_users_report.csv"
      elsif request.format.xlsx?
        send_data generate_xlsx(users, "Active Users Report"), filename: "active_users_report.xlsx"
      else
        render json: { error: "Unsupported format" }, status: :bad_request
      end
    end

    # 3. Report of posts with comment count
    def posts_report
      posts = Post.left_joins(:comments)
                  .select("posts.id, posts.title, posts.description, COUNT(comments.id) AS comments_count")
                  .group("posts.id")

      if request.format.csv?
        send_data generate_csv(posts), filename: "posts_report.csv"
      elsif request.format.xlsx?
        send_data generate_xlsx(posts, "Posts Report"), filename: "posts_report.xlsx"
      else
        render json: { error: "Unsupported format" }, status: :bad_request
      end
    end

    private

    def authorize_admin
      unless current_user.has_role?(:admin)
        render json: { error: "Unauthorized" }, status: :forbidden
      end
    end

    def generate_csv(records)
      return "" if records.empty?

      CSV.generate(headers: true) do |csv|
        csv << records.first.attributes.keys # Column headers
        records.each { |record| csv << record.attributes.values }
      end
    end

    def generate_xlsx(records, sheet_name)
      return "" if records.empty?

      package = Axlsx::Package.new
      package.workbook.add_worksheet(name: sheet_name) do |sheet|
        sheet.add_row records.first.attributes.keys # Column headers
        records.each { |record| sheet.add_row record.attributes.values }
      end
      package.to_stream.read
    end
  end
end
