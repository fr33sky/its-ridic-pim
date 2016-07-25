class AddAccountTypeToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :account_type, :string
  end
end
