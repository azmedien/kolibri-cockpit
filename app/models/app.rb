class App < ApplicationRecord
  include FriendlyId
  include Authority::Abilities
  include CopyCarrierwaveFile

  resourcify
  has_paper_trail only: %i[runtime android_config ios_config internal_name internal_id]

  self.authorizer_name = 'AppsAuthorizer'

  belongs_to :user

  has_many :builds, dependent: :destroy
  has_many :assets, dependent: :destroy

  accepts_nested_attributes_for :assets

  validates :internal_name, uniqueness: true, presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  mount_uploader :android_icon, IconsUploader
  mount_uploader :ios_icon, IconsUploader
  mount_uploader :splash, SplashUploader

  mount_uploader :android_firebase, FirebaseUploader
  mount_uploader :ios_firebase, FirebaseUploader

  store %(:android_config :ios_config)

  has_secure_token :internal_id
  friendly_id :internal_id

  before_create :set_slug
  after_create :set_role

  def self.android_bundle_id?(bundle_id)
    apps = App.where('android_config ? :key', key: 'bundle_id')
    app = apps.where('android_config @> hstore(:key, :value)',
                     key: 'bundle_id', value: bundle_id).first

    !app.nil?
  end

  def self.ios_bundle_id?(bundle_id)
    apps = App.where('ios_config ? :key', key: 'bundle_id')
    app = apps.where('ios_config @> hstore(:key, :value)',
                     key: 'bundle_id', value: bundle_id).first
    !app.nil?
  end

  def origin?
    return App.exists?(android_config['origin']) if android_config['origin']
  end

  def origin
    App.find(android_config['origin'])
  end

  def icon?
    android_icon? || ios_icon?
  end

  def icon
    icon = android_icon if android_icon?

    unless icon
      icon = ios_icon if ios_icon?
    end

    icon
  end

  def android_config=(new_config)
    gs = android_config || {}
    gs = gs.merge(new_config || {})
    write_attribute(:android_config, gs)
  end

  def ios_config=(new_config)
    gs = ios_config || {}
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
    if new_record?
      self.slug = internal_id
      self.internal_slug = internal_name.parameterize
    end
  end

  def set_role
    user.add_role(:admin, self)
  end
end
