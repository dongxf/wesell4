namespace :counter_cache do
  desc "update counter cache"
  task :update_instance => :environment do
    Instance.all.each do |instance|
      instance.kategories_count = instance.kategories.count
      instance.stores_count     = instance.stores.count
      instance.orders_count     = instance.orders.count
      instance.customers_count  = instance.customers.count
      instance.save(validate: false)
      print "update #{instance.name}..\n"
    end
    print "#{Instance.all.count} instances updated\n"
  end

  task :update_store => :environment do
    Store.all.each do |store|
      store.categories_count   = store.categories.count
      store.instances_count    = store.instances.count
      store.wesell_items_count = store.wesell_items.count
      store.orders_count       = store.orders.count
      store.save(validate: false)
      print "update #{store.name}..\n"
    end
    print "#{Store.all.count} stores updated\n"
  end

  task :update_village_item => :environment do
    VillageItem.find_each do |vi|
      vi.update commenters_count: vi.comments.group(:customer_id).length
      print "update #{vi.name}..\n"
    end
    print "Done"
  end
end
