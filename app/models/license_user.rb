class LicenseUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :license, counter_cache: :users_count

  default_scope { order('license_users.created_at DESC') }
end
