class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.string :description
      t.integer :qbo_id

      t.timestamps null: false
    end
  end
end
