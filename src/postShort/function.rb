require 'json'
require 'logger'
require 'aws-sdk-dynamodb'
require 'securerandom'

FOUR_HUNDRED = {
  statusCode: 400,
  body: 'request could not be processed'
}

FOUR_OH_NINE = {
  statusCode: 409,
  body: 'requested short already taken'
}

VALID_SHORT_URL_CHARS = /\A[a-zA-Z0-9\-_]+\z/
VALID_PARAMS          = ['short_url', 'full_url'].freeze

def parse(body)
  params = body&.split('&')
  return nil if params.empty?

  params.map { |p| p.split('=') }.select { |p| VALID_PARAMS.include?(p.first) }.to_h
end

def validate(params)
  unless params['short_url'].match?(VALID_SHORT_URL_CHARS)
    raise 'invalid character in given param'
  end
end

def generate_short(params)
  {
    'pk' => params['short_url'],
    'full_url' => params['full_url'],
    'created_at' => Time.now.utc.iso8601,
    'uuid' => SecureRandom.uuid,
    'user_generated' => true,
  }
end

def handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info(JSON.dump(event))

  params = parse(event['body'])
  return FOUR_HUNDRED if params.empty?
  validate(params)

  item = generate_short(params)
  client = Aws::DynamoDB::Client.new()
  put_params = {
    condition_expression: 'attribute_not_exists(pk)',
    item: item,
    return_consumed_capacity: 'NONE',
    table_name: ENV['TABLE_NAME'], 
  }
  result = client.put_item(put_params)

  {
    statusCode: 201,
    body: params.to_json
  }
rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
  return FOUR_OH_NINE
rescue
  return FOUR_HUNDRED
end
