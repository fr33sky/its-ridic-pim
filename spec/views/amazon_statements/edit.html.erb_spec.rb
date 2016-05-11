require 'rails_helper'

RSpec.describe "amazon_statements/edit", type: :view do
  before(:each) do
    @amazon_statement = assign(:amazon_statement, AmazonStatement.create!(
      :period => "MyString",
      :deposit_total => "9.99",
      :status => "MyString",
      :settlement_id => "MyString",
      :summary => "MyText"
    ))
  end

  it "renders the edit amazon_statement form" do
    render

    assert_select "form[action=?][method=?]", amazon_statement_path(@amazon_statement), "post" do

      assert_select "input#amazon_statement_period[name=?]", "amazon_statement[period]"

      assert_select "input#amazon_statement_deposit_total[name=?]", "amazon_statement[deposit_total]"

      assert_select "input#amazon_statement_status[name=?]", "amazon_statement[status]"

      assert_select "input#amazon_statement_settlement_id[name=?]", "amazon_statement[settlement_id]"

      assert_select "textarea#amazon_statement_summary[name=?]", "amazon_statement[summary]"
    end
  end
end
