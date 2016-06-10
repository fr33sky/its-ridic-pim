class AddQboIdToSales < ActiveRecord::Migration
  def change
    add_column :sales, :qbo_id, :integer
  end
end
