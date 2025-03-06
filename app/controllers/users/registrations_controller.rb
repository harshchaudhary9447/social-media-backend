# frozen_string_literal: true

# require "debug"

module Users
  class RegistrationsController < Devise::RegistrationsController
    include RackSessionFix

    before_action :configure_sign_up_params, only: [ :create ]
    before_action :configure_account_update_params, only: [ :update ]

    private

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone_number ])
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone_number ])
    end

    # Custom JSON response for user sign-up
    def respond_with(resource, _opts = {})
    # binding.break
    puts resource
      if request.method == "POST" && resource.persisted?

        # UserMailer.welcome_email(resource).deliver

        render json: {
          status: { code: 200, message: "Signed up successfully." },
          data: resource
        }, status: :ok
      elsif request.method == "DELETE"
        render json: {
          status: { code: 200, message: "Account deleted successfully." }
        }, status: :ok
      else
        render json: {
          message: "User is not able to create account",
          error: resource.errors.full_messages.to_sentence
        }, status: :unprocessable_entity

      end
    end
  end
end
