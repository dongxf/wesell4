class ChangePaymentOptionsMask < ActiveRecord::Migration
  def change
    Store.where('payment_options_mask = 10').update_all(payment_options_mask: 9)
    Store.where('payment_options_mask = 8').update_all(payment_options_mask: 1)
  end
end
