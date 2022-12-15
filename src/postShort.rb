require 'json'
require 'logger'
require_relative './ddb'
require_relative './short'

FOUR_HUNDRED = {
  statusCode: 400,
  body: 'request could not be processed'
}

FOUR_OH_NINE = {
  statusCode: 409,
  body: 'requested short already taken'
}

VALID_PARAMS = ['short_url', 'full_url'].freeze

def parse(body)
  params = body&.split('&')
  return nil if params.empty?

  params.map { |p| p.split('=') }.select { |p| VALID_PARAMS.include?(p.first) }.to_h
end

def handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info(JSON.dump(event))

  params = parse(event['body'])
  return FOUR_HUNDRED if params.empty?

  short = Short.new(params['short_url'], params['full_url'])
  return FOUR_HUNDRED unless short.valid?

  save_short(short)

  {
    statusCode: 201,
    body: short.to_s
  }
rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
  return FOUR_OH_NINE
rescue
  return FOUR_HUNDRED
end
