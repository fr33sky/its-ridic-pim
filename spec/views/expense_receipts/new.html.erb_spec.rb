require 'rails_helper'

RSpec.describe "expense_receipts/new", type: :view do
  before(:each) do
    assign(:expense_receipt, ExpenseReceipt.new(
      :description => "MyString"
    ))
  end

  it "renders new expense_receipt form" do
    render

    assert_select "form[action=?][method=?]", expense_receipts_path, "post" do

      assert_select "input#expense_receipt_description[name=?]", "expense_receipt[description]"
    end
  end
end
