class AddDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :user_date, :datetime
  end
end
