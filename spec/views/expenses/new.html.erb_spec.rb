require 'rails_helper'

RSpec.describe "expenses/new", type: :view do
  before(:each) do
    assign(:expense, Expense.new(
      :expense_account => nil,
      :description => "MyString",
      :amount => 1.5
    ))
  end

  it "renders new expense form" do
    render

    assert_select "form[action=?][method=?]", expenses_path, "post" do

      assert_select "input#expense_expense_account_id[name=?]", "expense[expense_account_id]"

      assert_select "input#expense_description[name=?]", "expense[description]"

      assert_select "input#expense_amount[name=?]", "expense[amount]"
    end
  end
end
