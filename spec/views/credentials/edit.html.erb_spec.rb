require 'rails_helper'

RSpec.describe "credentials/edit", type: :view do
  before(:each) do
    @credential = assign(:credential, Credential.create!(
      :primary_marketplace_id => "MyString",
      :merchant_id => "MyString",
      :auth_token => "MyString"
    ))
  end

  it "renders the edit credential form" do
    render

    assert_select "form[action=?][method=?]", credential_path(@credential), "post" do

      assert_select "input#credential_primary_marketplace_id[name=?]", "credential[primary_marketplace_id]"

      assert_select "input#credential_merchant_id[name=?]", "credential[merchant_id]"

      assert_select "input#credential_auth_token[name=?]", "credential[auth_token]"
    end
  end
end
