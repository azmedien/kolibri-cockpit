class App < ApplicationRecord
  include Authority::Abilities

  belongs_to :user
  has_many :builds, dependent: :destroy

  validates :internal_name, uniqueness: true,  presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  mount_uploaders :android_icons, AssetsUploader
  mount_uploaders :ios_icons, AssetsUploader
  mount_uploaders :assets, AssetsUploader
  mount_uploaders :splash, AssetsUploader
  serialize :android_icons, JSON
  serialize :ios_icons, JSON
  serialize :assets, JSON

  store %(:android_config :ios_config)

  has_secure_token :internal_id
end
