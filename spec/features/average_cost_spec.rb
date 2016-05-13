require "rails_helper"
include ActiveSupport::Testing::TimeHelpers

describe "Average Cost" do
  scenario "with no orders" do
    product = FactoryGirl.create(:product)
    order = FactoryGirl.create(:order)
    order_item = FactoryGirl.create(:order_item, order: order, product: product, quantity: 500, cost: 500.00)
    p order_item.reload
    expect(order_item.reload.average_cost).to eq(1.00)
  end

  scenario "with multiple orders" do
    product = FactoryGirl.create(:product)
    order = FactoryGirl.create(:order)
    order_item = FactoryGirl.create(:order_item, order: order, product: product, quantity: 500, cost: 500.00)
    sales_receipt = FactoryGirl.create(:sales_receipt)
    sale = FactoryGirl.create(:sale, sales_receipt: sales_receipt, product: product, quantity: 300, amount: 3000.00)
    order2 = FactoryGirl.create(:order, name: "Order 2")
    order_item2 = FactoryGirl.create(:order_item, order: order2, product: product, quantity: 500, cost: 675)
    expect(order_item2.reload.average_cost).to eq(1.25)
  end

  scenario "with order, 2 sales, and then 'oops' order" do
    # Create order and sale 3 days ago
    travel_to(3.days.ago) do
      @product    = FactoryGirl.create(:product)
      @order      = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500.00)
      @sales_receipt = FactoryGirl.create(:sales_receipt)
      @sale          = FactoryGirl.create(:sale, sales_receipt: @sales_receipt, product: @product, quantity: 300, amount: 3000.00)
    end

    expect(@order_item.average_cost).to eq(1.00)

    # Create a sale for yesterday (1 day ago)
    travel_to(1.day.ago) do
      @sales_receipt2 = FactoryGirl.create(:sales_receipt)
      @sale2 = FactoryGirl.create(:sale, sales_receipt: @sales_receipt2, product: @product, quantity: 200, amount: 2000.00)
    end

    # Create order for 2 days ago ("oops" order)
    @order2      = FactoryGirl.create(:order, user_date: 2.days.ago)
    @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 500, cost: 556.00)
    expect(@order_item2.average_cost).to eq(1.08)
  end

  scenario "with order, 2 sales, oops order, 2 sales, oops order" do
    travel_to(10.days.ago) do
      @product = FactoryGirl.create(:product)
      @order   = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500)
    end

    expect(@order_item.average_cost).to eq(1.00)

    travel_to(9.days.ago) do
      @sales_receipt = FactoryGirl.create(:sales_receipt)
      @sale = FactoryGirl.create(:sale, sales_receipt: @sales_receipt, product: @product, quantity: 300, amount: 3000.00)
    end

    travel_to(5.days.ago) do
      @sales_receipt2 = FactoryGirl.create(:sales_receipt)
      @sale2 = FactoryGirl.create(:sale, sales_receipt: @sales_receipt2, product: @product, quantity: 200, amount: 2000.00)
    end

    # Order with user date of 7 days ago
    @order2      = FactoryGirl.create(:order, user_date: 7.days.ago)
    @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 500, cost: 556)

    expect(@order_item2.average_cost).to eq(1.08)

    travel_to(4.days.ago) do
      @sales_receipt3 = FactoryGirl.create(:sales_receipt)
      @sale3 = FactoryGirl.create(:sale, sales_receipt: @sales_receipt3, product: @product, quantity: 200, amount: 2000.00)
    end

    travel_to(2.days.ago) do
      @sales_receipt4 = FactoryGirl.create(:sales_receipt)
      @sale4 = FactoryGirl.create(:sale, sales_receipt: @sales_receipt4, product: @product, quantity: 200, amount: 2000.00)
    end

    # Order with user date of 3 days ago
    @order3      = FactoryGirl.create(:order, user_date: 3.days.ago)
    @order_item3 = FactoryGirl.create(:order_item, order: @order3, product: @product, quantity: 300, cost: 300)

    expect(@order_item3.average_cost).to eq(1.04)
  end

  scenario "overlapping oops orders" do
    travel_to(3.days.ago) do
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500)
    end

    expect(@order_item.average_cost).to eq(1.00)

    @order2 = FactoryGirl.create(:order, user_date: 1.day.ago)
    @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 200, cost: 250.00)
    
    expect(@order_item2.average_cost).to be_within(0.01).of(1.07)

    @order3 = FactoryGirl.create(:order, user_date: 2.days.ago)
    @order_item3 = FactoryGirl.create(:order_item, order: @order3, product: @product, quantity: 100, cost: 150.00)

    expect(@order_item2.reload.average_cost).to eq(1.125)
    expect(@order_item3.reload.average_cost).to be_within(0.005).of(1.08)
  end

  scenario "multiple overlapping orders" do
    travel_to(4.days.ago) do
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500)
    end

    travel_to(2.days.ago) do
      @order2 = FactoryGirl.create(:order)
      @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 200, cost: 250.00)
    end

    travel_to(1.days.ago) do
      @order3 = FactoryGirl.create(:order)
      @order_item3 = FactoryGirl.create(:order_item, order: @order3, product: @product, quantity: 1500, cost: 200.00)
    end

    @order4 = FactoryGirl.create(:order, user_date: 3.days.ago)
    @order_item4 = FactoryGirl.create(:order_item, order: @order4, product: @product, quantity: 100, cost: 150.00)

    expect(@order_item3.reload.average_cost).to be_within(0.05).of(0.478)
  end

  scenario "multiple overlapping orders with sales" do
    travel_to(4.days.ago) do
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500)
    end

    expect(@order_item.average_cost).to eq(1.00)

    travel_to(3.days.ago) do
      @sales_receipt = FactoryGirl.create(:sales_receipt)
      @sale = FactoryGirl.create(:sale, sales_receipt: @sales_receipt, product: @product, quantity: 300, amount: 3000.00)
    end

    expect(@order_item.reload.average_cost).to eq(1.00)

    travel_to(2.days.ago - 3000) do
      @sales_receipt2 = FactoryGirl.create(:sales_receipt)
      @sale2 = FactoryGirl.create(:sale, sales_receipt: @sales_receipt2, product: @product, quantity: 100, amount: 3000.00)
    end

    travel_to(2.days.ago) do
      @order2 = FactoryGirl.create(:order)
      @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 200, cost: 250.00)
    end

    travel_to(1.days.ago) do
      @order3 = FactoryGirl.create(:order)
      @order_item3 = FactoryGirl.create(:order_item, order: @order3, product: @product, quantity: 1500, cost: 200.00)
    end

    @order4 = FactoryGirl.create(:order, user_date: 3.days.ago + 3000)
    @order_item4 = FactoryGirl.create(:order_item, order: @order4, product: @product, quantity: 100, cost: 150.00)

    expect(@order_item4.average_cost).to be_within(0.001).of(1.166667)

    expect(@order_item3.reload.average_cost).to be_within(0.05).of(0.438)
  end
end
