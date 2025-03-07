class Relationship::UnfollowUser < ApplicationService
  attr_reader :unfollower, :unfollowed_user

  def initialize(unfollower:, unfollowed_user:)
    super()

    @unfollower = unfollower
    @unfollowed_user = unfollowed_user
  end

  private

  def execute
    raise ArgumentError, 'Invalid unfollower or unfollowed user.' unless valid_user?(unfollower) && valid_user?(unfollowed_user)

    raise ArgumentError, 'User cannot unfollow themselves.' if unfollower == unfollowed_user

    Relationship.find_by!(follower: unfollower, followed_user: unfollowed_user).delete
  rescue ActiveRecord::RecordNotFound
    raise Error, 'User is not following this person.'
  end
end
