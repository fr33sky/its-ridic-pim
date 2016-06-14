class ExpenseReceipt < ActiveRecord::Base
  belongs_to :bank_account
  has_many :expenses, dependent: :destroy
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
end
