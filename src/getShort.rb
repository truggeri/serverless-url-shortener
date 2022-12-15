require 'json'
require 'logger'
require_relative './ddb'

FOUR_OH_FOUR = {
  statusCode: 404,
  body: 'short not found'
}

def handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info(JSON.dump(event))

  short = event["path"]&.tr('/', '')
  return FOUR_OH_FOUR if short.nil?

  data = load_short(short)
  return FOUR_OH_FOUR if data.nil?

  {
    statusCode: 302,
    headers: {
      Location: data['full_url']
    }
  }
rescue
  return FOUR_OH_FOUR
end
