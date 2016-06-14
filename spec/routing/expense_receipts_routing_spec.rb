require "rails_helper"

RSpec.describe ExpenseReceiptsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/expense_receipts").to route_to("expense_receipts#index")
    end

    it "routes to #new" do
      expect(:get => "/expense_receipts/new").to route_to("expense_receipts#new")
    end

    it "routes to #show" do
      expect(:get => "/expense_receipts/1").to route_to("expense_receipts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/expense_receipts/1/edit").to route_to("expense_receipts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/expense_receipts").to route_to("expense_receipts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/expense_receipts/1").to route_to("expense_receipts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/expense_receipts/1").to route_to("expense_receipts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/expense_receipts/1").to route_to("expense_receipts#destroy", :id => "1")
    end

  end
end
