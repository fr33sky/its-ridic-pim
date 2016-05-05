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

  factory :sale do
    product
    payment
    contact
    quantity 300
    sale_price 3000
  end
end
