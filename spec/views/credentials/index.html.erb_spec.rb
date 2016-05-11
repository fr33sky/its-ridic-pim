require 'rails_helper'

RSpec.describe "credentials/index", type: :view do
  before(:each) do
    assign(:credentials, [
      Credential.create!(
        :primary_marketplace_id => "Primary Marketplace",
        :merchant_id => "Merchant",
        :auth_token => "Auth Token"
      ),
      Credential.create!(
        :primary_marketplace_id => "Primary Marketplace",
        :merchant_id => "Merchant",
        :auth_token => "Auth Token"
      )
    ])
  end

  it "renders a list of credentials" do
    render
    assert_select "tr>td", :text => "Primary Marketplace".to_s, :count => 2
    assert_select "tr>td", :text => "Merchant".to_s, :count => 2
    assert_select "tr>td", :text => "Auth Token".to_s, :count => 2
  end
end
