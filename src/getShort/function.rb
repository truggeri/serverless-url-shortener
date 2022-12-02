require 'json'
require 'logger'
require 'aws-sdk-dynamodb'

FOUR_OH_FOUR = {
  statusCode: 404,
  body: 'short not found'
}

def handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info(JSON.dump(event))

  short = event["path"]&.tr('/', '')
  return FOUR_OH_FOUR if short.nil?

  client = Aws::DynamoDB::Client.new()
  query_params = {
    expression_attribute_values: {
      ':v1' => short, 
    }, 
    key_condition_expression: 'pk = :v1', 
    table_name: ENV['TABLE_NAME'], 
  }
  result = client.query(query_params)
  return FOUR_OH_FOUR if result[:items].empty?

  {
    statusCode: 302,
    headers: {
      Location: result[:items].first['full_url']
    }
  }
rescue
  return FOUR_OH_FOUR
end
