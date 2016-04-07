class AddAvatarToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :avatar,   :string,  default: '', null: false
    add_column :customers, :province, :string,  default: '', null: false
    add_column :customers, :city,     :string,  default: '', null: false
    add_column :customers, :country,  :string,  default: '', null: false
    add_column :customers, :nickname, :string,  default: '', null: false
    add_column :customers, :gender,   :integer, default: 0,  null: false
  end
end
