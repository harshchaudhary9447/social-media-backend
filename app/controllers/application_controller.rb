class ApplicationController < ActionController::API
  before_action :authenticate_user!
  before_action :ensure_json_request

  private

  def ensure_json_request
    request.format = :json if request.format.html?
  end
end
