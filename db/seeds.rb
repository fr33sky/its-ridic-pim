# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Config.create(question: "When creating an expense receipt, what is the default account used?",
                   class_name: "Account", account_type: "Bank")
Config.create(question: "When creating an expense receipt, what is the default customer?",
                   class_name: "Contact")
Config.create(question: "When creating a sales receipt, what is the default customer?", class_name: "Contact")
Config.create(question: "When creating a sales receipt, what is the deposit to account?", class_name: "Account")
Config.create(question: "When creating a product in QBO, what is the income account used?", class_name: "Account", account_type: "Income")
Config.create(question: "What account do you want Amazon 'Shipping' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'SaleTax' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'PromotionShipping' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'ShippingSalesTax' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'FBAGiftWrap' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'BalanceAdjustment' to go to?", class_name: "Account")
Config.create(question: "What account do you want Amazon 'GiftWrapTax' to go to?", class_name: "Account")
Config.create(question: "What account do you want unknown Amazon to go to?", class_name: "Account")
