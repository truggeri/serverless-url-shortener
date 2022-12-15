require 'json'
require 'logger'
require_relative './ddb'
require_relative './token'

FOUR_OH_ONE = {
  statusCode: 401,
  body: 'authorization invalid'
}
FOUR_OH_FOUR = {
  statusCode: 404,
  body: 'short not found'
}

def authenticate(event)
  auth = event["headers"]["Authorization"]
  return nil if auth.nil?

  tokens = auth.split
  return nil if tokens.size != 2 || tokens.first.downcase != 'bearer'

  payload = Token.decode(tokens[1])
  return nil unless !payload.nil? && payload['iss'] == Token::ISSUER && !payload['uuid'].nil?

  { iat: payload['iat'], uuid: payload['uuid'] }
end

def authorize(data, authorization)
  token_for_request = data['uuid'] == authorization[:uuid]
  token_times_match = true #(authorization[:iat] - data['created_at'].to_i) < 10

  return token_for_request && token_times_match
end

def handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info(JSON.dump(event))

  short = event["path"]&.tr('/', '')
  return FOUR_OH_FOUR if short.nil?

  data = load_short(short)
  return FOUR_OH_FOUR if data.nil?

  authorization = authenticate(event)
  return FOUR_OH_ONE if authorization.nil? || !authorize(data, authorization)

  delete_short(short)
  {
    statusCode: 202,
  }
rescue
  return FOUR_OH_FOUR
end
