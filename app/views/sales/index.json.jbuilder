json.array!(@sales) do |sale|
  json.extract! sale, :id, :product_id, :payment_id, :contact_id, :sale_price
  json.url sale_url(sale, format: :json)
end
