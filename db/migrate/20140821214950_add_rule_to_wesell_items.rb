class AddRuleToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :rule, :string, null: false, default: 'norm'
  end
end
