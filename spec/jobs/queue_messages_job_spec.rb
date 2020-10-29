require 'rails_helper'

RSpec.describe QueueMessagesJob, type: :job do
    describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        QueueMessagesJob.perform_later()
      }.to have_enqueued_job
    end
  end

end

