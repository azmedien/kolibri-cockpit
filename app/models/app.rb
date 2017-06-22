class App < ApplicationRecord
  include FriendlyId
  include Authority::Abilities
  include CopyCarrierwaveFile

  belongs_to :user
  has_many :builds, dependent: :destroy
  has_many :assets, dependent: :destroy
  accepts_nested_attributes_for :assets

  validates :internal_name, uniqueness: true,  presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  mount_uploader :android_icon, IconsUploader
  mount_uploader :ios_icon, IconsUploader
  mount_uploader :splash, IconsUploader

  mount_uploader :android_firebase, FirebaseUploader
  mount_uploader :ios_firebase, FirebaseUploader

  store %(:android_config :ios_config)

  has_secure_token :internal_id
  friendly_id :internal_id

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

  def duplicate_files(original)
    copy_carrierwave_file(original, self, :android_icon) unless android_icon.file.nil?
    copy_carrierwave_file(original, self, :ios_icon) unless ios_icon.file.nil?
    copy_carrierwave_file(original, self, :splash) unless splash.file.nil?
  end

  private
  def set_slug
    self.slug = internal_id
  end
end
