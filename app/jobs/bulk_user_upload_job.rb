require "csv"
require "roo"

class BulkUserUploadJob < ApplicationJob
  queue_as :default

  def perform(file_path, admin_email)
    users_created = 0
    errors = []

    begin
      extension = File.extname(file_path).downcase
      Rails.logger.info "Processing bulk upload file: #{file_path}, Format: #{extension}"

      case extension
      when ".csv"
        users_created, errors = process_csv(file_path)
      when ".xls", ".xlsx"
        users_created, errors = process_xlsx(file_path)
      else
        errors << "Unsupported file format: #{extension}"
      end
    rescue CSV::MalformedCSVError => e
      errors << "CSV parsing error: #{e.message}"
    rescue Roo::Error => e
      errors << "Spreadsheet error: #{e.message}"
    rescue StandardError => e
      errors << "Unexpected error: #{e.message}"
      Rails.logger.error "Bulk Upload Error: #{e.message}"
    ensure
      # Debugging: File deletion disabled temporarily
      Rails.logger.info "File exists at: #{file_path}" if File.exist?(file_path)
    end

    # Send report email
    AdminMailer.bulk_upload_report(admin_email, users_created, errors).deliver_now
  end

  private

  def process_csv(file_path)
    users_created = 0
    errors = []

    CSV.foreach(file_path, headers: true) do |row|
      user_data = row.to_h.transform_keys(&:downcase) # Normalize headers
      result = create_user(user_data)
      result[:success] ? users_created += 1 : errors << result[:error]
    end

    [ users_created, errors ]
  end

  def process_xlsx(file_path)
    users_created = 0
    errors = []

    xlsx = Roo::Spreadsheet.open(file_path)
    sheet = xlsx.sheet(0)

    headers = sheet.row(1).map(&:downcase)
    sheet.each_with_index do |row, index|
      next if index.zero?

      user_data = Hash[headers.zip(row)]
      result = create_user(user_data)
      result[:success] ? users_created += 1 : errors << result[:error]
    end

    [ users_created, errors ]
  end

  def create_user(user_data)
    user = User.new(
      first_name: user_data["first_name"],
      last_name: user_data["last_name"],
      email: user_data["email"],
      password: user_data["password"] || SecureRandom.hex(8),
      phone_number: user_data["phone_number"]
    )

    if user.save
      user.add_role(:normal)
      { success: true }
    else
      error_msg = "Failed to create user #{user_data['email']}: #{user.errors.full_messages.join(', ')}"
      Rails.logger.error error_msg
      { success: false, error: error_msg }
    end
  end
end
