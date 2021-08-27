# frozen_string_literal: true

# User controller
class Api::V1::PasswordsController < Api::BaseController
  skip_before_action :authenticate_request!, only: %i[reset_password_instructions]

  def reset_password_instructions
    user = User.find_by(email: password_params[:email])
    if user.not_nil?
      user.reset_password_token = SecureRandom.uuid
      user.reset_password_sent_at = Time.now
      user.save
      JwtMailer.reset_password(user.id, user.reset_password_token).deliver
      render json: { message: 'reset password instructions sent' }, status: :ok
    else
      render json: { message: 'email not found' }, status: :not_found
    end
  end

  def update_password
    # make sure reset_password_token is in params
    unless user_reset_token_in_token?
      return render json: { errors: ['Unauthorized'] },
                    status: :unauthorized
    end

    # TODO: make a better error message
    return render json: { errors: ['Error'] } unless user_found? &&
                                                     passwords_match?(password_params[:password],
                                                                      password_params[:password_confirmation])

    password_update(password_params[:password])
  end

  private

  def user_found?
    # Find user by reset_password_token
    @current_user = User.find(auth_token[:reset_password_token])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Unauthorized'] }, status: :unauthorized

    return false unless @current_user.not_nil?

    true
  end

  def password_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  end

  def passwords_match?(password, password_confirmation)
    return false if password.not_nil? && password != password_confirmation

    true
    # render json: { message: "passwords don't match" },
    #        status: :unprocessable_entity
  end

  def password_update(passwd)
    # Update password
    if @current_user.update(password: passwd)
      render json: { message: 'password updated' }, status: :ok
    else
      render json: @current_user.errors, status: :unprocessable_entity
    end
  end
end