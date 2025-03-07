class SleepRecord::Feed < ApplicationService
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  private

  def execute
    raise ArgumentError, 'Invalid user.' unless valid_user?(user)

    SleepRecord.includes(:user)
               .where(user_id: User.where(id: user.following.select(:id)))
               .where(sleep_at: 1.week.ago.beginning_of_day...Time.now)
               .order(duration: :desc)
  end
end
