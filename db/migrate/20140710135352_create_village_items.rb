class CreateVillageItems < ActiveRecord::Migration
  def change
    create_table :village_items do |t|
	t.integer :village_id
	t.string  :name
	t.string  :tel
	t.string  :addr
	t.string  :link
	t.text    :info
	t.integer :call_count, default: 0
      t.string  :logo

      t.timestamps
    end

    add_index :village_items, :village_id
  end
end
