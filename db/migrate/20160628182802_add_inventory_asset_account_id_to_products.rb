class AddInventoryAssetAccountIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :inventory_asset_account_id, :integer
  end
end
