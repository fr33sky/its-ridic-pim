class AddQboIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :qbo_id, :integer
  end
end
