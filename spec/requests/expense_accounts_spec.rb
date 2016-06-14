require 'rails_helper'

RSpec.describe "ExpenseAccounts", type: :request do
  describe "GET /expense_accounts" do
    it "works! (now write some real specs)" do
      get expense_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
