class RemoveExpenseAccountIdFromExpenses < ActiveRecord::Migration
  def change
    remove_column :expenses, :expense_account_id
  end
end
