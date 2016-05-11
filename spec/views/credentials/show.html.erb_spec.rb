require 'rails_helper'

RSpec.describe "credentials/show", type: :view do
  before(:each) do
    @credential = assign(:credential, Credential.create!(
      :primary_marketplace_id => "Primary Marketplace",
      :merchant_id => "Merchant",
      :auth_token => "Auth Token"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Primary Marketplace/)
    expect(rendered).to match(/Merchant/)
    expect(rendered).to match(/Auth Token/)
  end
end
