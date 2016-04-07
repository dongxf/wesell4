class AddCsaToInstances < ActiveRecord::Migration
  def change
    #this flag indicated if any service rep is available to the customer
    add_column :instances, :csa, :boolean, null: false, default: true
  end
end
