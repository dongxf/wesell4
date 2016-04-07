class AddCreditToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :credit, :integer, default: 0
    add_column :instances, :openid, :string
    add_column :instances, :qrcode, :string
  end
end
