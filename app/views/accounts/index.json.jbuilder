json.array!(@accounts) do |account|
  json.extract! account, :id, :name, :description, :account_type, :qbo_id
  json.url account_url(account, format: :json)
end
