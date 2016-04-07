class ChangePaymentOptionsBits < ActiveRecord::Migration
  def change
    Store.where('payment_options_mask = 1').update_all(payment_options_mask: 8)
    Store.where('payment_options_mask = 9').update_all(payment_options_mask: 10)
  end
end
