class AddDescriptionToSales < ActiveRecord::Migration
  def change
    add_column :sales, :description, :string
  end
end
