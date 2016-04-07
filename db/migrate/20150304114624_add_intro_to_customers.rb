class AddIntroToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :intro, :text
  end
end
