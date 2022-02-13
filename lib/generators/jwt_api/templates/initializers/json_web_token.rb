# frozen_string_literal: true

# JSON Web Token class
class JsonWebToken
  def initialize(key = Rails.application.credentials[:secret_key_base], algorithm = 'HS256')
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
