class AddClickCountToSubTags < ActiveRecord::Migration
  def change
    add_column :sub_tags, :click_count, :integer, default: 0
  end
end
