require "rails_helper"

RSpec.describe ExpenseAccountsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/expense_accounts").to route_to("expense_accounts#index")
    end

    it "routes to #new" do
      expect(:get => "/expense_accounts/new").to route_to("expense_accounts#new")
    end

    it "routes to #show" do
      expect(:get => "/expense_accounts/1").to route_to("expense_accounts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/expense_accounts/1/edit").to route_to("expense_accounts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/expense_accounts").to route_to("expense_accounts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/expense_accounts/1").to route_to("expense_accounts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/expense_accounts/1").to route_to("expense_accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/expense_accounts/1").to route_to("expense_accounts#destroy", :id => "1")
    end

  end
end
