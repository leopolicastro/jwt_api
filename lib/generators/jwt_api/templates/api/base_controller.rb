# frozen_string_literal: true

# Base controller for API
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_request!

  protected

  def authenticate_request!
    user_id_in_token?
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Unauthorized'] }, status: :unauthorized
  end

  private

  def http_token
    @http_token ||= (request.headers['Authorization'].split.last if request.headers['Authorization'].present?)
  end

  def auth_token
    @auth_token ||= jwt.decode(http_token)[0].to_h.symbolize_keys!
    return nil if token_expired?
    return @auth_token if @auth_token.present? && @auth_token[:user_id].present? && jti_matches?
  end

  def token_expired?
    @auth_token[:exp] < Time.now.to_i
  end

  def jti_matches?
    @current_user = User.find(@auth_token[:user_id])
    @current_user&.jti == @auth_token[:jti]
  end

  def user_id_in_token?
    http_token && auth_token
  end

  def user_reset_token_in_params?
    params[:reset_password_token]
  end

  def jwt
    JsonWebToken.new
  end
end
