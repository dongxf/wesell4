class AddStartedAtToOffers < ActiveRecord::Migration
  def up
    add_column :offers, :started_at, :datetime
    remove_column :offers, :begin_at
  end

  def down
    remove_column :offers, :started_at
  end
end
