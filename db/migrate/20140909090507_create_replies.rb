class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.string :replyable_type
      t.integer :replyable_id
      t.text   :hash_content
      t.string :status
      t.integer :user_id
      t.string  :msg_id

      t.timestamps
    end

    add_index :replies, [:replyable_id]
  end
end
