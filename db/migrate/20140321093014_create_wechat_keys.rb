class CreateWechatKeys < ActiveRecord::Migration
  def change
    create_table :wechat_keys do |t|
      t.references :instance, index: true
      t.string :tips
      t.string :key
      t.text :content

      t.timestamps
    end
  end
end
