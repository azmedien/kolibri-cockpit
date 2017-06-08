class App < ApplicationRecord
  extend FriendlyId

  include Authority::Abilities

  friendly_id :internal_id, use: [:slugged, :finders]

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

  before_create :set_slug

  def android_config=(new_config)
    gs = self.android_config || {}
    gs = gs.merge(new_config || {})
    write_attribute(:android_config, gs)
  end

  def ios_config=(new_config)
    gs = self.ios_config || {}
    gs = gs.merge(new_config || {})
    write_attribute(:ios_config, gs)
  end

  private
  def set_slug
    self.slug = internal_id
  end
end
