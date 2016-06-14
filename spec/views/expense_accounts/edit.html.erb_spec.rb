require 'rails_helper'

RSpec.describe "expense_accounts/edit", type: :view do
  before(:each) do
    @expense_account = assign(:expense_account, ExpenseAccount.create!(
      :name => "MyString",
      :description => "MyString",
      :qbo_id => 1
    ))
  end

  it "renders the edit expense_account form" do
    render

    assert_select "form[action=?][method=?]", expense_account_path(@expense_account), "post" do

      assert_select "input#expense_account_name[name=?]", "expense_account[name]"

      assert_select "input#expense_account_description[name=?]", "expense_account[description]"

      assert_select "input#expense_account_qbo_id[name=?]", "expense_account[qbo_id]"
    end
  end
end
