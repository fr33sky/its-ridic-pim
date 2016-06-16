class CreateConfigs < ActiveRecord::Migration
  def change
    create_table :configs do |t|
      t.string :question
      t.string :class_name
      t.integer :config_id

      t.timestamps null: false
    end
  end
end
