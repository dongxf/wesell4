class Operation < ActiveRecord::Base
  include Spreadable

  belongs_to :instance, counter_cache: :stores_count
  belongs_to :store, counter_cache: :instances_count
  belongs_to :kategory, counter_cache: :stores_count

  validates_presence_of :instance_id, :store_id
  validates_uniqueness_of :instance_id, scope: :store_id

  default_scope { order('operations.sequence ASC, operations.id ASC') }

  searchable do
    text :instance_nick do
      instance.nick
    end
    text :store_name do
      store.name
    end
    text :kategory_name do
      kategory.present? ? kategory.name : ''
    end
    text :description do
      store.description
    end
    boolean :open do
      store.open?
    end
    integer :instance_id
    integer :store_id
    integer :sequence
  end

  def gen_sceneid
    return self.sceneid if self.sceneid.present?
    loop do
      sid = rand(100..100000)
      break self.sceneid = sid unless ( self.instance.village_items.exists?(sceneid: sid) && self.instance.operations.exists?(sceneid: sid) )
    end
    save
    return self.sceneid
  end
end
