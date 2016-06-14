require 'rails_helper'

RSpec.describe "expense_accounts/show", type: :view do
  before(:each) do
    @expense_account = assign(:expense_account, ExpenseAccount.create!(
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
