# frozen_string_literal: true

# User controller
class Api::V1::UsersController < Api::BaseController
  skip_before_action :authenticate_request!, only: %i[create]
  def create
    unless user_params[:password] == user_params[:password_confirmation]
      return render json: { message: "passwords don't match" }, status: :unprocessable_entity
    end

    user = User.new(user_params)
    user.jti = SecureRandom.uuid
    if user.save
      render partial: 'users/user', locals: { user: user }, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # '/api/v1/me'
  def me
    render partial: 'users/user', locals: { user: @current_user }
  end

  def update
    @current_user.update(user_params.except(:password_confirmation, :reset_password_token))
    render partial: 'users/user', locals: { user: @current_user }
  end

  def destroy
    @current_user.destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:email, :password,
                                 :password_confirmation)
  end
end
