class Village < ActiveRecord::Base
	belongs_to :instance
  has_many   :leagueships, dependent: :destroy

	has_many   :village_items, through: :leagueships
  has_many   :comments, through: :village_items

	validates :name, presence: true, :uniqueness => true
	validates :instance_id, presence: true

  mount_uploader :logo, LogoUploader
  mount_uploader :banner, BannerUploader

  searchable do
    text :name,    stored: true
    text :slogan,     stored: true
    text :desc,    stored: true
    integer :id
  end

  def css
    return User.find_by id: Ownership.where(target_type: "Village", target_id: self.id, role_identifier: "css").pluck(:user_id)
  end

  def ccas
    return User.where id: Ownership.where(target_type: "Village", target_id: self.id, role_identifier: "cca").pluck(:user_id)
  end

end
