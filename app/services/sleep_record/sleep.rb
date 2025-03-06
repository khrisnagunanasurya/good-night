class SleepRecord::Sleep < ApplicationService
  attr_reader :user, :sleep_at

  def initialize(user:)
    super()

    @user = user
    @sleep_at = Time.now
  end

  private

  def execute
    raise ArgumentError, 'Invalid user.' unless valid_user?

    user.with_lock do
      last_record = user.sleep_records.last

      raise Error, 'You already have an ongoing sleep record' if last_record && last_record.wake_up_at.nil?

      SleepRecord.create!(user: user, sleep_at: sleep_at)
    end
  end

  def valid_user?
    user.is_a?(User) && user.persisted?
  end
end
