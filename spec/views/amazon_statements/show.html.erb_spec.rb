require 'rails_helper'

RSpec.describe "amazon_statements/show", type: :view do
  before(:each) do
    @amazon_statement = assign(:amazon_statement, AmazonStatement.create!(
      :period => "Period",
      :deposit_total => "9.99",
      :status => "Status",
      :settlement_id => "Settlement",
      :summary => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Period/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Settlement/)
    expect(rendered).to match(/MyText/)
  end
end
