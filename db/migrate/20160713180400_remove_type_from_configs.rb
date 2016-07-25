class RemoveTypeFromConfigs < ActiveRecord::Migration
  def change
    remove_column :configs, :type, :string
  end
end
