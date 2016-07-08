# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

q1 = Config.create(question: "When creating an expense account, what is the default account used?",
                   class_name: "BankAccount")

q2 = Config.create(question: "When creating an expense account, what is the default customer?",
                   class_name: "Contact")

q3 = Config.create(question: "When creating a sales receipt, what is the default customer?", class_name: "Contact")

q4 = Config.create(question: "When creating a sales receipt, what is the deposit to account?", class_name: "BankAccount")

q5 = Config.create(question: "When creating a product in QBO, what is the income account used?", class_name: "IncomeAccount")

q6 = Config.create(question: "What account do you want Amazon 'Shipping' to go to?", class_name: "MultipleAccounts")
q7 = Config.create(question: "What account do you want Amazon 'PromotionShipping' to go to?", class_name: "MultipleAccounts")
q8 = Config.create(question: "What account do you want Amazon 'ShippingSalesTax' to go to?", class_name: "MultipleAccounts")
q9 = Config.create(question: "What account do you want Amazon 'FBAGiftWrap' to go to?", class_name: "MultipleAccounts")
q10 = Config.create(question: "What account do you want Amazon 'GiftWrap' to go to?", class_name: "MultipleAccounts")
q11 = Config.create(question: "What account do you want unknown Amazon to go to?", class_name: "MultipleAccounts")
