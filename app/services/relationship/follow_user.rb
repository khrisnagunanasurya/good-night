class Relationship::FollowUser < ApplicationService
  attr_reader :follower, :followed_user

  def initialize(follower:, followed_user:)
    super()

    @follower = follower
    @followed_user = followed_user
  end

  private

  def execute
    raise ArgumentError, 'Invalid follower or followed user.' unless valid_input?

    raise ArgumentError, 'User cannot follow themselves.' if follower == followed_user

    Relationship.lock.create!(follower: follower, followed_user: followed_user)
  rescue ActiveRecord::RecordNotUnique
    raise Error, 'Already following this user.'
  end

  def valid_input?
    follower.is_a?(User) && followed_user.is_a?(User) && follower.persisted? && followed_user.persisted?
  end
end
