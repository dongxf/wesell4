class AddWxpayConfigsToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :partner_id, :string
    add_column :instances, :partner_key, :string
    add_column :instances, :pay_sign_key, :string
  end
end
