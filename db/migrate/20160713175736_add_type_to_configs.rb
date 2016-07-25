class AddTypeToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :type, :string
  end
end
