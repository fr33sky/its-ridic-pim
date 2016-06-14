require 'rails_helper'

RSpec.describe "bank_accounts/new", type: :view do
  before(:each) do
    assign(:bank_account, BankAccount.new(
      :name => "MyString",
      :description => "MyString",
      :qbo_id => 1
    ))
  end

  it "renders new bank_account form" do
    render

    assert_select "form[action=?][method=?]", bank_accounts_path, "post" do

      assert_select "input#bank_account_name[name=?]", "bank_account[name]"

      assert_select "input#bank_account_description[name=?]", "bank_account[description]"

      assert_select "input#bank_account_qbo_id[name=?]", "bank_account[qbo_id]"
    end
  end
end
