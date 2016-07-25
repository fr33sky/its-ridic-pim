class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :description
      t.string :account_type
      t.integer :qbo_id

      t.timestamps null: false
    end
  end
end
