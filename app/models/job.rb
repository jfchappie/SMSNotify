class Job < ApplicationRecord
  validates :name, presence: true
  validates :message, presence: true 
end
