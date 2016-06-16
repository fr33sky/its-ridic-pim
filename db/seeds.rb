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

