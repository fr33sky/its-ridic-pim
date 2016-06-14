json.array!(@expenses) do |expense|
  json.extract! expense, :id, :expense_account_id, :description, :amount
  json.url expense_url(expense, format: :json)
end
