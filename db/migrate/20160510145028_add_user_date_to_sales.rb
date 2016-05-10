class AddUserDateToSales < ActiveRecord::Migration
  def change
    add_column :sales, :user_date, :datetime
  end
end
