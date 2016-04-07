class License < ActiveRecord::Base
  has_many :license_users
  has_many :users, through: :license_users

  def self.to_options
    all.map {|l| {value: l.id, text: l.name}}
  end
end
