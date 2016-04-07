class DataFixer
  def set_vid_for_items
    #for those items has been created without village_ids
    VillageItem.where('village_id is null').each do |vi|
      vi.update_attributes(village_id: vi.instance.villages.first.id)
    end
  end
end
