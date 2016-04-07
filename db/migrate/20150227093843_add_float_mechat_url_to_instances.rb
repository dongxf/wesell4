class AddFloatMechatUrlToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :float_mechat_url, :string, default: ''
  end
end
