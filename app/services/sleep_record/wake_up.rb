class SleepRecord::WakeUp < ApplicationService
  attr_reader :user, :wake_up_at

  def initialize(user:)
    super()

    @user = user
    @wake_up_at = Time.now
  end

  private

  def execute
    raise ArgumentError, 'Invalid user.' unless valid_user?(user)

    last_record = user.sleep_records.last

    raise Error, 'You haven\'t sleep yet' if last_record.nil? || last_record.wake_up_at.present?

    last_record.update!(wake_up_at: wake_up_at)
    last_record
  end
end
