# frozen_string_literal: true

require 'jwt'
require_relative 'jwt_api/version'

module JwtApi
  class Jwt
    def initialize(key, algorithm = 'HS256')
      @key = key
      @algorithm = algorithm
    end

    def encode(payload)
      JWT.encode(payload, @key, @algorithm)
    end

    def decode(token)
      JWT.decode(token, @key, @algorithm)
    end
  end
end

class JsonWebToken
  def self.encode(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def self.decode(token)
    HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.secrets.secret_key_base)[0])
  rescue StandardError
    nil
  end
end