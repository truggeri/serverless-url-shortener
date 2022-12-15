require 'aws-sdk-dynamodb'

def load_short(short)
  client = Aws::DynamoDB::Client.new()
  query_params = {
    expression_attribute_values: {
      ':v1' => short, 
    }, 
    key_condition_expression: 'pk = :v1', 
    table_name: ENV['TABLE_NAME'], 
  }
  result = client.query(query_params)
  return nil if result[:items].empty?

  result[:items].first
end

def save_short(short)
  client = Aws::DynamoDB::Client.new()
  put_params = {
    condition_expression: 'attribute_not_exists(pk)',
    item: short.to_h,
    return_consumed_capacity: 'NONE',
    table_name: ENV['TABLE_NAME'], 
  }
  result = client.put_item(put_params)
end