json.array!(@adjustments) do |adjustment|
  json.extract! adjustment, :id, :product_id, :adjustment_type_id, :adjusted_quantity
  json.url adjustment_url(adjustment, format: :json)
end
