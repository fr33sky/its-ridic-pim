class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.references :accounts, index: true, foreign_key: true
      t.string :description
      t.float :amount

      t.timestamps null: false
    end
  end
end
