json.array!(@amazon_statements) do |amazon_statement|
  json.extract! amazon_statement, :id, :period, :deposit_total, :status, :settlement_id, :summary
  json.url amazon_statement_url(amazon_statement, format: :json)
end
