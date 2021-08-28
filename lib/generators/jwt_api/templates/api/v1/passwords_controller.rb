# frozen_string_literal: true

# User controller
class Api::V1::PasswordsController < Api::BaseController
  skip_before_action :authenticate_request!, only: %i[reset_password_instructions verify]

  # Password Reset Flow
  # 1. User requests password reset instructions by sending params with email
  # to /api/v1/passwords/reset

  def reset_password_instructions
    @user = User.find_by(email: password_params[:email])
    if @user.nil?
      render json: { message: 'email not found' }, status: :not_found
    else
      @user.reset_password_token = SecureRandom.uuid
      @user.reset_password_sent_at = Time.now
      if @user.save
        JwtMailer.reset_password(@user.id, @user.reset_password_token).deliver
        render json: { message: 'reset password instructions sent' }, status: :ok
      else
        render json: { message: @user.errors }, status: :not_found
      end
    end
  end

  # Step 2: User clicks on link in email which sends them to /api/v1/passwords/verify
  # with a token in the params, if a succesful response is received, the client can
  # store the newly issued JWT and redirect the user to the password reset form
  def verify
    @user = User.where(reset_password_token: params[:token]).first
    if @user.nil?
      render json: { message: 'reset password token not found' }, status: :not_found
    elsif @user.reset_password_sent_at < 1.hour.ago
      render json: { message: 'reset password token has expired' }, status: :not_found
    else
      @user.reset_password_token = nil
      @user.reset_password_sent_at = nil
      @user.jti = SecureRandom.uuid
      @user.save

      iat = Time.now.to_i
      exp = Time.now.to_i + 10 * 60

      render json: {
        token: JsonWebToken.encode({ user_id: @user.id,
                                     jti: @user.jti,
                                     iat: iat,
                                     exp: exp })
      }, status: :ok
    end
  end

  # Step 3: User submits password reset form with new password and includes
  # the newly issued Bearer token within 10 minutes of issuing the token
  def update_password
    if user_found? && passwords_match?(password_params[:password],
                                       password_params[:password_confirmation])

      password_update(password_params[:password])
    end
  end

  private

  def user_found?
    @user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Unauthorized'] }, status: :unauthorized

    true
  end

  def passwords_match?(password, password_confirmation)
    return false if password.nil? || (password != password_confirmation)

    true
  end

  def password_update(password)
    if @user.update(password: password, jti: SecureRandom.uuid)
      render json: { message: 'password updated' }, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def password_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  end
end
