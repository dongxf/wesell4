class ChangeTotalIncomeForReports < ActiveRecord::Migration
  def change
    change_column :reports, :total_income, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
