class AddQboIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :qbo_id, :integer
  end
end
