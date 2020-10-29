class ChangeVendorResponseIDtoString < ActiveRecord::Migration[5.2]
  def change
    change_column :notifications, :vendor_response_id, :string
  end
end
