class AddTemplateIdToInstances < ActiveRecord::Migration
  def up
    add_column :instances, :template_id, :string
  end

  def down
    remove_column :instances, :template_id
  end
end
