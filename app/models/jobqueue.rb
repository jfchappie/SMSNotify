class Jobqueue < ApplicationRecord
  scope :active, -> { where(status: 6).where('jobqueues.retry_count <  jobqueues.retry_threshold') }
end
