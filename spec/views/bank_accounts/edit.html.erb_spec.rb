require 'rails_helper'

RSpec.describe "bank_accounts/edit", type: :view do
  before(:each) do
    @bank_account = assign(:bank_account, BankAccount.create!(
      :name => "MyString",
      :description => "MyString",
      :qbo_id => 1
    ))
  end

  it "renders the edit bank_account form" do
    render

    assert_select "form[action=?][method=?]", bank_account_path(@bank_account), "post" do

      assert_select "input#bank_account_name[name=?]", "bank_account[name]"

      assert_select "input#bank_account_description[name=?]", "bank_account[description]"

      assert_select "input#bank_account_qbo_id[name=?]", "bank_account[qbo_id]"
    end
  end
end
