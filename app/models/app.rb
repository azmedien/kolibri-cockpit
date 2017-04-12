class App < ApplicationRecord
  include Authority::Abilities

  belongs_to :user
  has_many :builds, dependent: :destroy
  has_many :assets, dependent: :destroy
  accepts_nested_attributes_for :assets

  validates :internal_name, uniqueness: true,  presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  mount_uploader :android_icon, AssetsUploader
  mount_uploader :ios_icon, AssetsUploader
  mount_uploader :splash, AssetsUploader

  store %(:android_config :ios_config)

  has_secure_token :internal_id
end
