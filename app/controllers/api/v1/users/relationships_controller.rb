class Api::V1::Users::RelationshipsController < ApplicationController
  before_action :set_user
  before_action :set_target_user

  # POST /api/v1/users/:user_id/relationships
  def create
    service = Relationship::FollowUser.call(follower: @user, followed_user: @target_user)

    if service.success?
      render json: { message: 'User followed successfully' }, status: :created
    else
      render_error(:unprocessable_content, service.error_message, service.error_details)
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def set_target_user
    @target_user = User.find_by(id: params[:target_user_id])
  end
end
