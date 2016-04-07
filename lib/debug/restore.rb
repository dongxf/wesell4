class Restore
  def parse
    base_url = '/home/deploy/neegen.com/wesell/shared'
    # base_url = '/Users/lifeixiong/Development/Fooways/wesell2/public'
    File.open("/tmp/dump.json", "r").each_line do |line|
      j = JSON.parse line
      klass, attrs = j.keys[0], j.values[0]
      case klass
      when 'user'
        @user = User.find_or_initialize_by(oldid: attrs['id'])
        @user.attributes = ({
          encrypted_password: attrs['encrypted_password'],
          email:              attrs['email'],
          name:               attrs['name'],
          sign_in_count:      attrs['sign_in_count']
        })
        if @user.save(validate: false)
          p '** restore user **'
        else
          p "USER ERROR: #{@user.errors.messages}"
        end

      when 'instance'
        @instance = Instance.find_or_initialize_by(oldid: attrs['id'])
        logo_url    = base_url + attrs['pic'].split('?')[0]
        banner_url  = base_url + attrs['banner'].split('?')[0]
        qrcode_url  = base_url + attrs['qr'].split('?')[0]
        logo_file   = File.exist?(logo_url)   ? File.open(logo_url)   : nil
        banner_file = File.exist?(banner_url) ? File.open(banner_url) : nil
        qrcode_file = File.exist?(qrcode_url) ? File.open(qrcode_url) : nil
        @instance.attributes = ({
          name:           attrs['name'],
          nick:           attrs['nick'],
          slogan:         attrs['slogan'],
          description:    attrs['description'],
          phone:          attrs['phone'].gsub(/\W/, ''),
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
        @instance.phone = '4000432013' if @instance.phone.blank?
        @user = User.find_by(oldid: attrs['user_id'])
        if @user.present?
          @instance.update_attributes(creator_id: @user.id)
          @instance.add_manager @user
        end
        if @instance.valid?
          p '** restore instance **'
        else
          p "INSTANCE ERROR: #{@instance.errors.messages}"
        end
      end
    end
  end
end
