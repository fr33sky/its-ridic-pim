require "rails_helper"

RSpec.describe AmazonStatementsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/amazon_statements").to route_to("amazon_statements#index")
    end

    it "routes to #new" do
      expect(:get => "/amazon_statements/new").to route_to("amazon_statements#new")
    end

    it "routes to #show" do
      expect(:get => "/amazon_statements/1").to route_to("amazon_statements#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/amazon_statements/1/edit").to route_to("amazon_statements#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/amazon_statements").to route_to("amazon_statements#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/amazon_statements/1").to route_to("amazon_statements#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/amazon_statements/1").to route_to("amazon_statements#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/amazon_statements/1").to route_to("amazon_statements#destroy", :id => "1")
    end

  end
end
