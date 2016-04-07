class AddCsTipToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :cs_tip, :string, default: '欢迎光临！使用过程中如需任何帮助，可点击右下角客服图标，必竭诚服务！' 
  end
end
