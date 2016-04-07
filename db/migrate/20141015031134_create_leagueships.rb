class CreateLeagueships < ActiveRecord::Migration
  def up
    create_table :leagueships do |t|
      t.references :village, index: true
      t.references :village_item, index: true

      t.timestamps
    end

    VillageItem.find_each do |vi|
      Leagueship.create village_id: vi.village_id, village_item_id: vi.id
    end
  end

  def down
    drop_table :leagueships
  end
end
