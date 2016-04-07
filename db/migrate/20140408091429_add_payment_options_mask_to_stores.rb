class AddPaymentOptionsMaskToStores < ActiveRecord::Migration
  def change
    add_column :stores, :payment_options_mask, :integer, default: 1
  end
end
