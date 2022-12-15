require 'json'
require 'securerandom'
require_relative './token'

INVALID_FULL_CHARS    = /[<>]+/
RESERVED_SHORTS       = %w[admin count health status system].freeze
VALID_SHORT_URL_CHARS = /\A[a-zA-Z0-9\-_]+\z/

class Short
  def initialize(short_url, full_url)
    @short_url = short_url
    @full_url = full_url
    @created_at = Time.now.utc
    @user_generated = true
    @uuid = SecureRandom.uuid
  end

  def to_s
    {
      'short_url' => short_url,
      'full_url' => full_url,
      'created_at' => created_at.iso8601,
      'token' => token
    }.to_json
  end

  def to_h
    {
      'pk' => short_url,
      'full_url' => full_url,
      'created_at' => created_at.iso8601,
      'user_generated' => user_generated,
      'uuid' => uuid
    }
  end

  def valid?
    return false if short_url.size < 4 || short_url.size > 100
    return false if RESERVED_SHORTS.include?(short_url)
    unless short_url.match?(VALID_SHORT_URL_CHARS)
      return false
    end
  
    return false if full_url.size < 3 || full_url.size > 100
    return false if full_url.match?(INVALID_FULL_CHARS)
    
    true
  end

  private
  
  attr_reader :created_at, :full_url, :short_url, :user_generated, :uuid

  def token
    Token.encode({ iat: created_at.to_i, uuid: uuid })
  end
end
