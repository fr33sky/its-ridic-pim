class RemoveExpenseAccountIdFromExpenses < ActiveRecord::Migration
  def change
    if column_exist?(:expense, :expense_account_id)
      remove_column :expenses, :expense_account_id
    end
  end
end
