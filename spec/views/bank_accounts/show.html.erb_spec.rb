require 'rails_helper'

RSpec.describe "bank_accounts/show", type: :view do
  before(:each) do
    @bank_account = assign(:bank_account, BankAccount.create!(
      :name => "Name",
      :description => "Description",
      :qbo_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/1/)
  end
end
