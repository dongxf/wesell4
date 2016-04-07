module Locatable
  def distance obj1, obj2
    Geocoder::Calculations.distance_between([obj1.latitude, obj1.longitude], [obj2.latitude, obj2.longitude])
  end

  def localized_stores stores, customer
    return stores unless self.check_location
    return [] unless customer.located?
    available = []
    no_distance = []
    stores.each do |store|
      if store.service_radius.blank?
        no_distance << store
      elsif store.service_radius >= distance(customer.location, store)
        store.distance = distance(customer.location, store) if store.located?
        available << store
      end
    end
    available.sort! { |x,y| x.distance <=> y.distance }
    available + no_distance
  end
end
