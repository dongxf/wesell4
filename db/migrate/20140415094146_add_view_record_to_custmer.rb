class AddViewRecordToCustmer < ActiveRecord::Migration
  def change
  	add_column :customers, :visit_count, :integer, default: 0
  	add_column :customers, :current_visit_at, :datetime
  	add_column :customers, :last_visit_at, :datetime
  	add_column :customers, :current_visit_ip, :string
  	add_column :customers, :last_visit_ip, :string
  end
end
