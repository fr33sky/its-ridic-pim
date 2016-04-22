json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :address, :city, :state, :postal_code, :country
  json.url contact_url(contact, format: :json)
end
