json.array!(@expense_receipts) do |expense_receipt|
  json.extract! expense_receipt, :id, :description
  json.url expense_receipt_url(expense_receipt, format: :json)
end
