require 'rails_helper'

RSpec.describe "amazon_statements/new", type: :view do
  before(:each) do
    assign(:amazon_statement, AmazonStatement.new(
      :period => "MyString",
      :deposit_total => "9.99",
      :status => "MyString",
      :settlement_id => "MyString",
      :summary => "MyText"
    ))
  end

  it "renders new amazon_statement form" do
    render

    assert_select "form[action=?][method=?]", amazon_statements_path, "post" do

      assert_select "input#amazon_statement_period[name=?]", "amazon_statement[period]"

      assert_select "input#amazon_statement_deposit_total[name=?]", "amazon_statement[deposit_total]"

      assert_select "input#amazon_statement_status[name=?]", "amazon_statement[status]"

      assert_select "input#amazon_statement_settlement_id[name=?]", "amazon_statement[settlement_id]"

      assert_select "textarea#amazon_statement_summary[name=?]", "amazon_statement[summary]"
    end
  end
end
