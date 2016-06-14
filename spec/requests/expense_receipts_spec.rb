require 'rails_helper'

RSpec.describe "ExpenseReceipts", type: :request do
  describe "GET /expense_receipts" do
    it "works! (now write some real specs)" do
      get expense_receipts_path
      expect(response).to have_http_status(200)
    end
  end
end
