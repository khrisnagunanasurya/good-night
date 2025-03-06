class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :sleep_at, presence: true

  before_save :calculate_sleep_duration

  private

  def calculate_sleep_duration
    if sleep_at.present? && wake_up_at.present?
      seconds_diff = (wake_up_at - sleep_at).to_i

      self.duration = seconds_diff
    end
  end
end
