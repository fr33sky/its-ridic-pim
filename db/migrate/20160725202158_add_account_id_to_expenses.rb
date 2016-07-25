class AddAccountIdToExpenses < ActiveRecord::Migration
  def change
    add_reference :expenses, :account, index: true, foreign_key: true
  end
end
