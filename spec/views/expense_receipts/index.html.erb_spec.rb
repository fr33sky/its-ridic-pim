require 'rails_helper'

RSpec.describe "expense_receipts/index", type: :view do
  before(:each) do
    assign(:expense_receipts, [
      ExpenseReceipt.create!(
        :description => "Description"
      ),
      ExpenseReceipt.create!(
        :description => "Description"
      )
    ])
  end

  it "renders a list of expense_receipts" do
    render
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
