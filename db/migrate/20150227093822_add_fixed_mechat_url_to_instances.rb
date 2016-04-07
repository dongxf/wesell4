class AddFixedMechatUrlToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :fixed_mechat_url, :string, defalt: ''
  end
end
