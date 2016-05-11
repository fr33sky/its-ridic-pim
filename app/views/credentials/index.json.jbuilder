json.array!(@credentials) do |credential|
  json.extract! credential, :id, :primary_marketplace_id, :merchant_id, :auth_token
  json.url credential_url(credential, format: :json)
end
