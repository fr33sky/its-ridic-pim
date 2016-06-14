FactoryGirl.define do
  factory :expense do
    expense_account nil
    description "MyString"
    amount 1.5
  end
end
