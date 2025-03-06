class Api::V1::UsersController < ApplicationController
  # GET api/v1/users
  def index
    render json: User.all
  end

  # GET api/v1/users/:id
  def show
    render json: User.find(params[:id])
  end

  # POST api/v1/users
  def create
    user =  User.new(permitted_params)

    if user.save
      render json: user, status: :created
    else
      render_error(:unprocessable_content, 'Failed to create a user', user.errors)
    end
  end

  # DELETE api/v1/users/:id
  def destroy
    user = User.find_by!(id: params[:id])

    if user.destroy
      head :no_content
    else
      render_error(:unprocessable_content, 'Failed to delete user', user.errors)
    end
  end

  private

  def permitted_params
    params.permit(:name)
  end
end
