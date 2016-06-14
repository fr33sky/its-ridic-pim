require 'rails_helper'

RSpec.describe "expense_accounts/index", type: :view do
  before(:each) do
    assign(:expense_accounts, [
      ExpenseAccount.create!(
        :name => "Name",
        :description => "Description",
        :qbo_id => 1
      ),
      ExpenseAccount.create!(
        :name => "Name",
        :description => "Description",
        :qbo_id => 1
      )
    ])
  end

  it "renders a list of expense_accounts" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
