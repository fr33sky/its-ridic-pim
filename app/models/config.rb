class Config < ActiveRecord::Base
  def self.expense_bank_account
    id = Config.find_by(question: "When creating an expense receipt, what is the default account used?").config_id
    Account.find_by(id: id)
  end

  def self.expense_customer
    id = Config.find_by(question: "When creating an expense receipt, what is the default customer?").config_id
    Contact.find_by(id: id)
  end

  def self.sales_receipt_customer
    id = Config.find_by(question: "When creating a sales receipt, what is the default customer?").config_id
    Contact.find_by(id: id).qbo_id
  end

  def self.sales_receipt_deposit_account
    id = Config.find_by(question: "When creating a sales receipt, what is the deposit to account?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.sales_receipt_income_account
    id = Config.find_by(question: "When creating a product in QBO, what is the income account used?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_shipping
    id = Config.find_by(question: "What account do you want Amazon 'Shipping' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_sale_tax
    id = Config.find_by(question: "What account do you want Amazon 'SaleTax' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_promotion_shipping
    id = Config.find_by(question: "What account do you want Amazon 'PromotionShipping' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_shipping_sales_tax
    id = Config.find_by(question: "What account do you want Amazon 'ShippingSalesTax' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_fba_gift_wrap
    id = Config.find_by(question: "What account do you want Amazon 'FBAGiftWrap' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_balance_adjustment
    id = Config.find_by(question: "What account do you want Amazon 'BalanceAdjustment' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_gift_wrap_tax
    id = Config.find_by(question: "What account do you want Amazon 'GiftWrapTax' to go to?").config_id
    Account.find_by(id: id).qbo_id
  end

  def self.classify_unknown
    id = Config.find_by(question: "What account do you want unknown Amazon to go to?").config_id
    Account.find_by(id: id).qbo_id
  end
end
