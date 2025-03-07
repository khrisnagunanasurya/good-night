class Api::V1::Users::SleepRecordsController < ApplicationController
  before_action :set_user

  # GET /api/v1/users/:user_id/sleep_records
  def index
    render json: @user.sleep_records
  end

  # POST /api/v1/users/:user_id/sleep
  def sleep
    service = SleepRecord::Sleep.call(user: @user)

    if service.success?
      render json: { message: 'Sleep record created successfully' }, status: :created
    else
      render_error(:unprocessable_content, service.error_message, service.error_details)
    end
  end

  # POST /api/v1/users/:user_id/wake_up
  def wake_up
    service = SleepRecord::WakeUp.call(user: @user)

    if service.success?
      render json: { message: 'Wake up record created successfully' }, status: :created
    else
      render_error(:unprocessable_content, service.error_message, service.error_details)
    end
  end

  private

  def set_user
    @user = User.find_by!(id: params[:user_id])
  end
end
