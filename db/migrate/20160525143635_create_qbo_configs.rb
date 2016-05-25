class CreateQboConfigs < ActiveRecord::Migration
  def change
    create_table :qbo_configs do |t|
      t.string :token
      t.string :secret
      t.string :realm_id

      t.timestamps null: false
    end
  end
end
