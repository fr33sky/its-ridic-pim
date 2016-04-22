class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :product, index: true, foreign_key: true
      t.references :payment, index: true, foreign_key: true
      t.references :contact, index: true, foreign_key: true
      t.float :sale_price

      t.timestamps null: false
    end
  end
end
