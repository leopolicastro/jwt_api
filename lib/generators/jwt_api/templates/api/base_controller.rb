# frozen_string_literal: true

# Base controller for API
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_request!

  protected

  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Unauthorized'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Unauthorized'] }, status: :unauthorized
  end

  private

  def http_token
    @http_token ||= if request.headers['Authorization'].present?
                      request.headers['Authorization'].split.last
                    end
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  rescue JWT::ExpiredSignature
    render json: { error: 'token expired' }
  end

  def jti_matches?
    @current_user = User.find(auth_token[:user_id])
    !@current_user.jti.nil? && @current_user.jti == auth_token[:jti]
  end

  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i && jti_matches?
  end

  # TODO: refactor this into user_id_in_token?
  def user_reset_token_in_params?
    params[:reset_password_token]
  end
end
