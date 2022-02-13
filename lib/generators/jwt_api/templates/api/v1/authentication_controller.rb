# frozen_string_literal: true

class Api::V1::AuthenticationController < Api::BaseController
  skip_before_action :authenticate_request!, only: [:authenticate_user]

  def authenticate_user
    user = User.find_for_database_authentication(email: params[:email])
    if !user.nil? && user.valid_password?(params[:password])
      render json: payload(user)
    else
      render json: { errors: ['Invalid Username/Password'] }, status: :unauthorized
    end
  end

  # Invalidate users JWT, logout user
  def logout
    @current_user.jti = SecureRandom.uuid
    if @current_user.save
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def payload(user)
    return nil unless user&.id

    iat = Time.now.to_i
    exp = Time.now.to_i + 24 * 3600

    {
      token: jwt.encode({ user_id: user.id,
                          jti: user.jti,
                          iat: iat,
                          exp: exp })
    }
  end
end
