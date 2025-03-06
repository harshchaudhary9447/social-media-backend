class UserMailer < ApplicationMailer
  default from: "harsh.chaudhary@jarvis.consulting" # Replace with your verified SendGrid sender email

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Maze! Let’s Get Started 🚀")
  end
end
