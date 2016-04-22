json.array!(@adjustment_types) do |adjustment_type|
  json.extract! adjustment_type, :id, :name
  json.url adjustment_type_url(adjustment_type, format: :json)
end
