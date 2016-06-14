require 'rails_helper'

RSpec.describe "expenses/edit", type: :view do
  before(:each) do
    @expense = assign(:expense, Expense.create!(
      :expense_account => nil,
      :description => "MyString",
      :amount => 1.5
    ))
  end

  it "renders the edit expense form" do
    render

    assert_select "form[action=?][method=?]", expense_path(@expense), "post" do

      assert_select "input#expense_expense_account_id[name=?]", "expense[expense_account_id]"

      assert_select "input#expense_description[name=?]", "expense[description]"

      assert_select "input#expense_amount[name=?]", "expense[amount]"
    end
  end
end
