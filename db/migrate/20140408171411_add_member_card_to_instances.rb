class AddMemberCardToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :member_card, :string
  end
end
