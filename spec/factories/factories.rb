FactoryGirl.define do
  factory :contact do
    name "Nate Dalo"
    address "123 Main St."
    city "Knoxville"
    state "IA"
    postal_code "50138"
    country "United States"
  end

  factory :payment do
    name "Cash"
  end

  factory :product do
    name "Product A"
    upc "123-456"
    price 10.00
  end

  factory :order do
    name "Order A"
  end

  factory :order_item do
    order
    product
    quantity 500
    cost 500.00
  end

  factory :sales_receipt do
    contact
    payment
  end

  factory :sale do
    sales_receipt
    product
    quantity 300
    amount 3000
  end
end
