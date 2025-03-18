
class AdminMailer < ApplicationMailer
  default from: "harsh.chaudhary@jarvis.consulting"

  def bulk_upload_report(admin_email, success_count, failed_count)
    @success_count = success_count
    @failed_count = failed_count

    mail(to: admin_email, subject: "Bulk User Upload Report")
  end
end
