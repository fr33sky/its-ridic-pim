json.array!(@products) do |product|
  json.extract! product, :id, :name, :upc, :price
  json.url product_url(product, format: :json)
end
