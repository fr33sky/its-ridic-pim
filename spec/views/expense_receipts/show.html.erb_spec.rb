require 'rails_helper'

RSpec.describe "expense_receipts/show", type: :view do
  before(:each) do
    @expense_receipt = assign(:expense_receipt, ExpenseReceipt.create!(
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Description/)
  end
end
