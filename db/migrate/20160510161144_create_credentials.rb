class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :primary_marketplace_id
      t.string :merchant_id
      t.string :auth_token

      t.timestamps null: false
    end
  end
end
