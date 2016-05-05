require "rails_helper"
include ActiveSupport::Testing::TimeHelpers

describe "Average Cost" do
  scenario "with no orders" do
    product = FactoryGirl.create(:product)
    order = FactoryGirl.create(:order)
    order_item = FactoryGirl.create(:order_item, order: order, product: product, quantity: 500, cost: 500.00)
    expect(order_item.average_cost).to eq(1.00)
  end

  scenario "with multiple orders" do
    product = FactoryGirl.create(:product)
    order = FactoryGirl.create(:order)
    order_item = FactoryGirl.create(:order_item, order: order, product: product, quantity: 500, cost: 500.00)
    sale = FactoryGirl.create(:sale, product: product, quantity: 300, sale_price: 3000.00)
    order2 = FactoryGirl.create(:order, name: "Order 2")
    order_item2 = FactoryGirl.create(:order_item, order: order2, product: product, quantity: 500, cost: 675)
    expect(order_item2.average_cost).to eq(1.25)
    sale2 = FactoryGirl.create(:sale, product: product, quantity: 50, sale_price: 500.00)
  end

  scenario "with order, 2 sales, and then 'oops' order" do
    # Create order and sale 3 days ago
    travel_to(3.days.ago) do
      @product    = FactoryGirl.create(:product)
      @order      = FactoryGirl.create(:order)
      @order_item = FactoryGirl.create(:order_item, order: @order, product: @product, quantity: 500, cost: 500.00)
      @sale       = FactoryGirl.create(:sale, product: @product, quantity: 300, sale_price: 3000.00)
    end

    expect(@order_item.average_cost).to eq(1.00)

    # Create a sale for yesterday (1 day ago)
    travel_to(1.day.ago) do
      @sale2 = FactoryGirl.create(:sale, product: @product, quantity: 200, sale_price: 2000.00)
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
      @sale = FactoryGirl.create(:sale, product: @product, quantity: 300, sale_price: 3000.00)
    end

    travel_to(5.days.ago) do
      @sale2 = FactoryGirl.create(:sale, product: @product, quantity: 200, sale_price: 2000.00)
    end

    # Order with user date of 7 days ago
    @order2      = FactoryGirl.create(:order, user_date: 7.days.ago)
    @order_item2 = FactoryGirl.create(:order_item, order: @order2, product: @product, quantity: 500, cost: 556)

    expect(@order_item2.average_cost).to eq(1.08)

    travel_to(4.days.ago) do
      @sale3 = FactoryGirl.create(:sale, product: @product, quantity: 200, sale_price: 2000.00)
    end

    travel_to(2.days.ago) do
      @sale4 = FactoryGirl.create(:sale, product: @product, quantity: 200, sale_price: 2000.00)
    end

    # Order with user date of 3 days ago
    @order3      = FactoryGirl.create(:order, user_date: 3.days.ago)
    @order_item3 = FactoryGirl.create(:order_item, order: @order3, product: @product, quantity: 300, cost: 300)

    expect(@order_item3.average_cost).to eq(1.04)
  end
end