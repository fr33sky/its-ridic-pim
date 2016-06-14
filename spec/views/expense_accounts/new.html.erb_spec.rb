require 'rails_helper'

RSpec.describe "expense_accounts/new", type: :view do
  before(:each) do
    assign(:expense_account, ExpenseAccount.new(
      :name => "MyString",
      :description => "MyString",
      :qbo_id => 1
    ))
  end

  it "renders new expense_account form" do
    render

    assert_select "form[action=?][method=?]", expense_accounts_path, "post" do

      assert_select "input#expense_account_name[name=?]", "expense_account[name]"

      assert_select "input#expense_account_description[name=?]", "expense_account[description]"

      assert_select "input#expense_account_qbo_id[name=?]", "expense_account[qbo_id]"
    end
  end
end
