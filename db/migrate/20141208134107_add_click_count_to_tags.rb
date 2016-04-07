class AddClickCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :click_count, :integer, default: 0
  end
end
