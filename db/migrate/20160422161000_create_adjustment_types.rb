class CreateAdjustmentTypes < ActiveRecord::Migration
  def change
    create_table :adjustment_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
