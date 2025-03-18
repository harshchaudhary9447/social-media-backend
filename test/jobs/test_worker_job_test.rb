class TestWorkerJob
  include Sidekiq::Worker  # Ensure Sidekiq processes this job

  def perform(name)
    puts "Hello, #{name}! This is a background job running in Sidekiq."
  end
end
