class Config < ActiveRecord::Base
  def self.expense_bank_account
    id = Config.find_by(question: "When creating an expense account, what is the default account used?").config_id
    BankAccount.find_by(id: id)
  end

  def self.expense_customer
    id = Config.find_by(question: "When creating an expense account, what is the default customer?").config_id
    Contact.find_by(id: id)
  end
end
