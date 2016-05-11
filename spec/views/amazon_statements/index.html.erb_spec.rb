require 'rails_helper'

RSpec.describe "amazon_statements/index", type: :view do
  before(:each) do
    assign(:amazon_statements, [
      AmazonStatement.create!(
        :period => "Period",
        :deposit_total => "9.99",
        :status => "Status",
        :settlement_id => "Settlement",
        :summary => "MyText"
      ),
      AmazonStatement.create!(
        :period => "Period",
        :deposit_total => "9.99",
        :status => "Status",
        :settlement_id => "Settlement",
        :summary => "MyText"
      )
    ])
  end

  it "renders a list of amazon_statements" do
    render
    assert_select "tr>td", :text => "Period".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "Settlement".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
