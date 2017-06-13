class Asset < ApplicationRecord
  extend FriendlyId
  include CopyCarrierwaveFile

  has_secure_token :slug
  friendly_id :slug, use: [:slugged, :finders]

  mount_uploader :file, AssetsUploader

  validates_integrity_of :file
  validates_processing_of :file
  validates :slug, uniqueness: { scope: :id }

  belongs_to :app
  before_destroy :internal_id

  def duplicate_file(original)
    copy_carrierwave_file(original, self, :file)
    self.save!
  end

  def internal_id(app_id = self.app_id)
    @internal_id = @internal_id || App.find(app_id).internal_id
  end
end
