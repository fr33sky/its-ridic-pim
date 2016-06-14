require 'rails_helper'

RSpec.describe "bank_accounts/index", type: :view do
  before(:each) do
    assign(:bank_accounts, [
      BankAccount.create!(
        :name => "Name",
        :description => "Description",
        :qbo_id => 1
      ),
      BankAccount.create!(
        :name => "Name",
        :description => "Description",
        :qbo_id => 1
      )
    ])
  end

  it "renders a list of bank_accounts" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
