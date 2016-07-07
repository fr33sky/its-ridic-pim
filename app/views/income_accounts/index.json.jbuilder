json.array!(@income_accounts) do |income_account|
  json.extract! income_account, :id, :name, :description, :qbo_id
  json.url income_account_url(income_account, format: :json)
end
