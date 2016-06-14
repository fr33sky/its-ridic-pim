require 'rails_helper'

RSpec.describe "expense_receipts/edit", type: :view do
  before(:each) do
    @expense_receipt = assign(:expense_receipt, ExpenseReceipt.create!(
      :description => "MyString"
    ))
  end

  it "renders the edit expense_receipt form" do
    render

    assert_select "form[action=?][method=?]", expense_receipt_path(@expense_receipt), "post" do

      assert_select "input#expense_receipt_description[name=?]", "expense_receipt[description]"
    end
  end
end
