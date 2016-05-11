class CreateAmazonStatements < ActiveRecord::Migration
  def change
    create_table :amazon_statements do |t|
      t.string :period
      t.decimal :deposit_total
      t.string :status
      t.string :settlement_id
      t.text :summary

      t.timestamps null: false
    end
  end
end
