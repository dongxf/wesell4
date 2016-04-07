#encoding: utf-8
namespace :restore do
  desc "dump instance and related data to json"
  task :instance, [:instance_id] => :environment do |task, args|
    base_url = '/home/deploy/neegen.com/wesell/shared'
    # base_url = '/Users/lifeixiong/Development/Fooways/wesell2/public'
    File.foreach("/var/backup/dump/#{args[:instance_id]}.json").with_index do |line, line_num|
      j = JSON.parse line
      klass, attrs = j.keys[0], j.values[0]
      case klass
      when 'user'
        user = User.find_or_initialize_by(oldid: attrs['id'])
        user.attributes = ({
          encrypted_password: attrs['encrypted_password'],
          email:              attrs['email'],
          name:               attrs['name'],
          sign_in_count:      attrs['sign_in_count']
        })
        if user.save(validate: false)
          p "#{line_num} restore user"
        else
          p "#{line_num}USER ERROR: #{user.errors.messages}"
          return
        end

      when 'instance'
        instance = Instance.find_or_initialize_by(oldid: attrs['id'])
        logo_url    = base_url + attrs['pic'].split('?')[0]
        banner_url  = base_url + attrs['banner'].split('?')[0]
        qrcode_url  = base_url + attrs['qr'].split('?')[0]
        logo_file   = File.exist?(logo_url)   ? File.open(logo_url)   : nil
        banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
        qrcode_file = File.exist?(qrcode_url) ? File.open(qrcode_url) : nil
        instance.attributes = ({
          name:           attrs['name'],
          nick:           attrs['nick'],
          slogan:         attrs['slogan'],
          description:    attrs['description'],
          phone:          attrs['phone'].blank? ? '' : attrs['phone'].split(',')[0].gsub(/\D/, ''),
          email:          attrs['email'],
          token:          attrs['token'],
          api_echoed:     attrs['api_echoed'],
          app_id:         attrs['app_id'],
          app_secret:     attrs['app_secret'],
          logo:           logo_file,
          banner:         banner_file,
          qrcode:         qrcode_file,
          latitude:       0,
          longitude:      0,
          check_location: attrs['using_location_address'],
          credit:         attrs['credit']
        })
        instance.phone = '4000432013' if instance.phone.blank?
        instance.save!
        user = User.find_by(oldid: attrs['user_id']) if attrs['user_id'].present?
        if user.present?
          instance.update_columns(creator_id: user.id)
          instance.add_manager user
          p "#{line_num} restore instance"
        else
          p "#{line_num} INSTANCE ERROR: #{instance.errors.messages}"
          return
        end

      when 'store'
        store = Store.find_or_initialize_by(oldid: attrs['id'])
        logo_url    = base_url + attrs['pic'].split('?')[0]
        banner_url  = base_url + attrs['banner'].split('?')[0]
        logo_file   = File.exist?(logo_url)   ? File.open(logo_url)   : nil
        banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
        store.attributes = ({
          name:           attrs['nick'],
          description:    attrs['description'].present? ? attrs['description'] : attrs['nick'],
          phone:          attrs['phone'].split(',')[0].gsub(/\D/, ''),
          email:          attrs['email'].split(',')[0],
          street:         attrs['address'],
          latitude:       attrs['latitude'],
          longitude:      attrs['longitude'],
          service_radius: attrs['service_radius'],
          logo:           logo_file,
          banner:         banner_file,
          monetary_unit:  '元',
          open:           attrs['active']
        })
        store.phone = '4000432013' if store.phone.blank?
        if store.save!
          user = User.find_by(oldid: attrs['user_id']) if attrs['user_id'].present?
          instance = Instance.find_by(oldid: attrs['instance_id']) if attrs['instance_id'].present?
          if user.present?
            store.update_column :creator_id, user.id
            store.add_manager(user)
          elsif instance.present? && instance.creator.present?
            store.update_column :creator_id, instance.creator_id
            store.add_manager(instance.creator)
          end
          if instance.present?
            store.instances << instance unless store.instances.include?(instance)
          end
          p "#{line_num} restore store"
        else
          p "#{line_num}STORE ERROR: #{store.inspect}"
          p "#{line_num}STORE ERROR: #{store.errors.messages}"
          return
        end

      when 'printer'
        printer = Printer.find_or_initialize_by(oldid: attrs['id'])
        printer.attributes = ({
          name:   attrs['name'],
          model:  attrs['model'],
          imei:   attrs['imei'],
          copies: attrs['copies'],
          status: attrs['status']
        })
        store = Store.find_by(oldid: attrs['westore_id']) if attrs['westore_id'].present?
        printer.store_id = store.id if store.present?
        printer.save!

      when 'category'
        category = Category.find_or_initialize_by(oldid: attrs['id'])
        category.attributes = ({name: attrs['name']})
        store = Store.find_by(oldid: attrs['westore_id']) if attrs['westore_id'].present?
        category.store_id = store.id if store.present?
        if category.save!
          p "#{line_num} restore category"
        else
          p "#{line_num}CATEGORY ERROR: #{category.errors.messages}"
        end

      when 'wesell_item'
        wesell_item = WesellItem.find_or_initialize_by(oldid: attrs['id'])
        image_url   = base_url + attrs['pic'].split('?')[0]
        banner_url  = base_url + attrs['banner'].split('?')[0]
        image_file  = File.exist?(image_url)  ? File.open(image_url)  : nil
        banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
        wesell_item.attributes = ({
          name:           attrs['name'],
          description:    attrs['description'],
          price:          attrs['price'],
          original_price: attrs['original_price'],
          unit_name:      attrs['unit_name']
        })
        wesell_item.image  = image_file if image_file.present?
        wesell_item.banner = banner_file if banner_file.present?
        wesell_item.unit_name = '份' if wesell_item.unit_name.blank?
        wesell_item.status = 10 if attrs['stop'] == true
        store = Store.find_by(oldid: attrs['westore_id']) if attrs['westore_id'].present?
        wesell_item.store_id = store.id if store.present?
        category = Category.find_by(oldid: attrs['category_id']) if attrs['category_id'].present?
        wesell_item.category_id = category.id if category.present?
        unless wesell_item.store_id.present?
          p "#{line_num} xxxxxxx wesell_item store is blank xxxxxxxxxx"
          p wesell_item.inspect
          next
        end
        if wesell_item.save(validate: false)
          p "#{line_num} restore wesell_item"
        else
          p "#{line_num}WESELL_ITEM ERROR: #{wesell_item.errors.messages}"
        end

      when 'option_group'
        wesell_item  = WesellItem.find_by(oldid: attrs['wesell_item_id']) if attrs['wesell_item_id'].present?
        option_group = wesell_item.options_groups.find_or_initialize_by(oldid: attrs['id'])
        option_group.attributes = ({
          name:           attrs['name'],
          style:          0
        })
        if option_group.save!
          p "#{line_num} restore option_group"
        else
          p "#{line_num} OPTION_GROUP ERROR: #{option_group.errors.messages}"
        end

      when 'wesell_item_option'
        wesell_item  = WesellItem.find_by(oldid: attrs['wesell_item_id']) if attrs['wesell_item_id'].present?
        option_group =  wesell_item.options_groups.find_by(oldid: attrs['item_option_id']) if attrs['item_option_id'].present?
        if option_group.present?
          wesell_item_option = option_group.wesell_item_options.find_or_initialize_by(
            name:           attrs['name'],
            price:          attrs['price_change']
          )
          if wesell_item_option.save!
            p "#{line_num} restore wesell_item_option"
          else
            p "#{line_num} OPTION_GROUP ERROR: #{wesell_item_option.errors.messages}"
          end
        else
          p "#{line_num} OPTION_GROUP is blank"
        end

      when 'customer'
        customer = Customer.find_or_initialize_by(openid: attrs['openid'])
        customer.oldid   = attrs['id']
        customer.balance = attrs['wonus_balance'] if customer.balance == 0
        case attrs['status']
        when 'rejected'
          customer.status = 1
        when 'unsubscribed'
          customer.status = 2
        end

        instance = Instance.find_by(oldid: attrs['instance_id']) if attrs['instance_id'].present?
        unless instance.present?
          p 'customer\'s intance not exist'
          return
        else
          customer.instance_id = instance.id
          if customer.save!
            p "#{line_num} restore customer"
          else
            p "#{line_num} CUSTOMER ERROR: #{customer.errors.messages}"
          end
        end

      when 'order'
        order = Order.find_or_initialize_by(oldid: attrs['id'])
        customer = Customer.find_by(oldid: attrs['wechat_user_id']) if attrs['wechat_user_id'].present?
        store    = Store.find_by(oldid: attrs['westore_id']) if attrs['westore_id'].present?
        instance = Instance.find_by(oldid: attrs['instance_id']) if attrs['instance_id'].present?
        next unless instance.present?
        next unless store.present?
        next unless customer.present?
        order.instance_id = instance.id
        order.store_id    = store.id
        order.customer_id = customer.id
        order.attributes = ({
          contact:   attrs['contact'],
          phone:     attrs['phone'],
          address:   attrs['address'],
          amount:    attrs['income'],
          comment:   attrs['description'],
          submit_at: attrs['updated_at']
        })
        if order.save!
          if attrs['status'] == 'closed'
            order.update_column :status, 'confirmed'
          else
            order.update_column :status, attrs['status']
          end
          p "#{line_num} restore order"
        else
          p "#{line_num} ORDER ERROR: #{order.errors.messages}"
        end

      when 'order_item'
        next if attrs['quantity'].to_i <= 0
        order_item = OrderItem.find_or_initialize_by(oldid: attrs['id'])
        order_item.attributes = ({
          quantity:   attrs['quantity'],
          unit_price: attrs['total_price'].to_f/attrs['quantity'],
          comment:    attrs['comment']
        })
        order = Order.find_by(oldid: attrs['wesell_order_id']) if attrs['wesell_order_id'].present?
        next unless order.present?
        wesell_item = WesellItem.find_by(oldid: attrs['wesell_item_id']) if attrs['wesell_item_id'].present?
        next unless wesell_item.present?
        order_item.order_id = order.id
        order_item.wesell_item_id = wesell_item.id
        if order_item.save
          p "#{line_num} restore order_item"
        else
          p "#{line_num} ORDER_ITEM ERROR: #{order_item.errors.messages}"
        end
      end
    end
  end

  task :image, [:instance_id] => :environment do |task, args|
    base_url = '/home/deploy/neegen.com/wesell/shared'
    # base_url = '/Users/lifeixiong/Development/Fooways/wesell2/public'
    File.foreach("/var/backup/dump/#{args[:instance_id]}.json").with_index do |line, line_num|
      j = JSON.parse line
      klass, attrs = j.keys[0], j.values[0]
      case klass
      when 'instance'
        instance = Instance.find_by(oldid: attrs['id'])
        if instance.present?
          logo_url    = base_url + attrs['pic'].split('?')[0]
          banner_url  = base_url + attrs['banner'].split('?')[0]
          qrcode_url  = base_url + attrs['qr'].split('?')[0]
          logo_file   = File.exist?(logo_url)   ? File.open(logo_url)   : nil
          banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
          qrcode_file = File.exist?(qrcode_url) ? File.open(qrcode_url) : nil
          instance.update_attributes({
            logo:           logo_file,
            banner:         banner_file,
            qrcode:         qrcode_file
          })
          p "**restore instance**"
        end
      when 'store'
        store = Store.find_by(oldid: attrs['id'])
        if store.present?
          logo_url    = base_url + attrs['pic'].split('?')[0]
          banner_url  = base_url + attrs['banner'].split('?')[0]
          logo_file   = File.exist?(logo_url)   ? File.open(logo_url)   : nil
          banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
          store.update_attributes({
            logo:           logo_file,
            banner:         banner_file
          })
          p "**restore store**"
        end
      when 'wesell_item'
        wesell_item = WesellItem.find_by(oldid: attrs['id'])
        if wesell_item.present?
          image_url   = base_url + attrs['pic'].split('?')[0]
          banner_url  = base_url + attrs['banner'].split('?')[0]
          image_file  = File.exist?(image_url)  ? File.open(image_url)  : nil
          banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
          wesell_item.update_attributes({
            image:  image_file,
            banner: banner_file
          })
          p "**restore wesell_item**"
        end
      end
    end
  end
end
