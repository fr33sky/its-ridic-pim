require 'rails_helper'

RSpec.describe "AmazonStatements", type: :request do
  describe "GET /amazon_statements" do
    it "works! (now write some real specs)" do
      get amazon_statements_path
      expect(response).to have_http_status(200)
    end
  end
end
