class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.references :product, index: true, foreign_key: true
      t.references :adjustment_type, index: true, foreign_key: true
      t.integer :adjusted_quantity

      t.timestamps null: false
    end
  end
end
